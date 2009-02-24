/**
 * Copyright (c) 2008, Jeremy Hinegardner
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include <stdlib.h>
#include <getopt.h>
#include <SDL.h>
#include <SDL_main.h>
#include <ruby.h>

/** from ruby's original main.c **/
#if defined(__MACOS__) && defined(__MWERKS__)
#include <console.h>
#endif

#include "crate_boot.h"

struct crate_app {
  char  *file_name;
  char  *class_name;
  VALUE  app_instance;
  char  *method_name;
  ID     run_method;
} ;

typedef struct crate_app crate_app; 

/* crate 'secret' options */
static struct option longopts[] = {
  { "crate-file",   required_argument, NULL, 1 },
  { "crate-class",  required_argument, NULL, 2 },
  { "crate-method", required_argument, NULL, 3 },
  { NULL,           0,                 NULL, 0 }
};

int crate_init_from_options(crate_app *ca, int argc, char** argv )
{
  int ch ;
  int done = 0;
  int old_opterr = opterr;

  /* turn off printing to stderr */
  opterr = 0;

  ca->file_name   = strdup( CRATE_MAIN_FILE );
  ca->class_name  = strdup( CRATE_MAIN_CLASS );
  ca->method_name = strdup( CRATE_RUN_METHOD );
    
  while ( !done && (ch = getopt_long( argc, argv, "", longopts, NULL ) ) != -1 ) {
    switch ( ch ) {
    case 1:
      free( ca->file_name );
      ca->file_name = strdup( optarg );
      break;

    case 2:
      free( ca->class_name );
      ca->class_name = strdup( optarg );
      break;

    case 3:
      free( ca->method_name );
      ca->method_name = strdup( optarg );
      break;

    default:
      /* if we have a non-option then we are done and be sure to decrement
       * optind so we keep the option that caused it to faile
       */
      done = 1;
      optind--;
      break;
    }
  }
 
  opterr = old_opterr;
  return optind;
}

/**
 * Make the actual application call, we call the application instance with the
 * method given and pass it ARGV and ENV in that order
 */
VALUE crate_wrap_app( VALUE arg )
{
  crate_app *ca = (crate_app*)arg;
  char *r = "Amalgalite::Requires.new( :dbfile_name => 'lib.db' )\n"\
            "Amalgalite::Requires.new( :dbfile_name => 'app.db' )\n";
  char buf[BUFSIZ];
  char* dot ;

  /* require the class file */

  dot = strchr( ca->file_name, '.');
  if ( NULL != dot ) { *dot = '\0' ; }
  sprintf( buf,"%s\nrequire '%s'", r, ca->file_name);
  rb_eval_string(buf);

  /* get an instance of the application class and pack up the instance and the
   * method 
   */
  ca->app_instance = rb_class_new_instance(0, 0, rb_const_get( rb_cObject, rb_intern( ca->class_name ) ) );
  ca->run_method   = rb_intern( ca->method_name );
 
  return rb_funcall( ca->app_instance, 
                     ca->run_method, 2, 
                     rb_const_get_at( rb_cObject, rb_intern("ARGV") ), 
                     rb_const_get_at( rb_cObject, rb_intern("ENV") ) );
}

static VALUE dump_backtrace( VALUE elem, VALUE n ) 
{
  fprintf( stderr, "\tfrom %s\n", RSTRING(elem)->ptr );
}

/**
 * ifdef items from ruby's original main.c
 */

/* to link startup code with ObjC support */
#if (defined(__APPLE__) || defined(__NeXT__)) && defined(__MACH__)
static void objcdummyfunction( void ) { objc_msgSend(); }
#endif

extern VALUE cARB;

int main( int argc, char** argv ) 
{
  int state  = 0;
  int rc     = 0;
  int opt_mv = 0;

  crate_app ca;

  /** startup items from ruby's original main.c */
#ifdef _WIN32
  NtInitialize(&argc, &argv);
#endif
#if defined(__MACOS__) && defined(__MWERKS__)
  argc = ccommand(&argv);
#endif

  /* setup ruby */
  ruby_init();
  ruby_script( argv[0] );
  ruby_init_loadpath();

  /* strip out the crate specific arguments from argv using --crate- */
  opt_mv = crate_init_from_options( &ca, argc, argv );
  argc -= opt_mv;
  argv += opt_mv;
 
  /* printf("crate file  : %s\n", ca.file_name);   */
  /* printf("crate class : %s\n", ca.class_name);  */
  /* printf("crate method: %s\n", ca.method_name); */

  /* make ARGV available */
  ruby_set_argv( argc, argv );

  /* initialize all extensions */
  Init_ext();

  /* load up the amalgalite libs */
  am_bootstrap_lift( cARB, Qnil );
 
  /* remove the current LOAD_PATH */
  rb_ary_clear( rb_gv_get( "$LOAD_PATH" ) );

  /* invoke the class / method passing in ARGV and ENV */
  rb_protect( crate_wrap_app, (VALUE)&ca, &state );

  /* check the results */
  if ( state ) {

    /* exception was raised, check the $! var */
    VALUE lasterr  = rb_gv_get("$!");
   
    /* system exit was called so just propogate that up to our exit */
    if ( rb_obj_is_instance_of( lasterr, rb_eSystemExit ) ) {

      rc = NUM2INT( rb_attr_get( lasterr, rb_intern("status") ) );
      /*printf(" Caught SystemExit -> $? will be %d\n", rc ); */

    } else {

      /* some other exception was raised so dump that out */
      VALUE klass     = rb_class_path( CLASS_OF( lasterr ) );
      VALUE message   = rb_obj_as_string( lasterr );
      VALUE backtrace = rb_funcall( lasterr, rb_intern("backtrace"), 0 );

      fprintf( stderr, "%s: %s\n", RSTRING( klass )->ptr, RSTRING( message )->ptr );
      rb_iterate( rb_each, backtrace, dump_backtrace, Qnil );

      rc = state;
    }
  } 

  free( ca.file_name );
  free( ca.class_name );
  free( ca.method_name );

  /* shut down ruby */
  ruby_finalize();

  /* exit the program */
  exit( rc );
}

