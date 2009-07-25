
# Basic event compatibility layer. Should allow most Gamebox games
# that use old-style Rubygame events to run using new-style events
# under the hood without even knowing it.


ExposeEvent      = Rubygame::Events::WindowExposed
KeyDownEvent     = Rubygame::Events::KeyPressed
KeyUpEvent       = Rubygame::Events::KeyReleased
MouseDownEvent   = Rubygame::Events::MousePressed
MouseUpEvent     = Rubygame::Events::MouseReleased
MouseMotionEvent = Rubygame::Events::MouseMoved
QuitEvent        = Rubygame::Events::QuitRequested
ResizeEvent      = Rubygame::Events::WindowResized




K_BACKSPACE    = :backspace
K_TAB          = :tab
K_CLEAR        = :clear
K_RETURN       = :return
K_PAUSE        = :pause
K_ESCAPE       = :escape
K_SPACE        = :space
K_EXCLAIM      = :exclamation_mark
K_QUOTEDBL     = :double_quote
K_HASH         = :hash
K_DOLLAR       = :dollar
K_AMPERSAND    = :ampersand
K_QUOTE        = :quote
K_LEFTPAREN    = :left_parenthesis
K_RIGHTPAREN   = :right_parenthesis
K_ASTERISK     = :asterisk
K_PLUS         = :plus
K_COMMA        = :comma
K_MINUS        = :minus
K_PERIOD       = :period
K_SLASH        = :slash
K_0            = :number_0
K_1            = :number_1
K_2            = :number_2
K_3            = :number_3
K_4            = :number_4
K_5            = :number_5
K_6            = :number_6
K_7            = :number_7
K_8            = :number_8
K_9            = :number_9
K_COLON        = :colon
K_SEMICOLON    = :semicolon
K_LESS         = :less_than
K_EQUALS       = :equals
K_GREATER      = :greater_than
K_QUESTION     = :question_mark
K_AT           = :at
K_LEFTBRACKET  = :left_bracket
K_BACKSLASH    = :backslash
K_RIGHTBRACKET = :right_bracket
K_CARET        = :caret
K_UNDERSCORE   = :underscore
K_BACKQUOTE    = :backquote
K_A            = :a
K_B            = :b
K_C            = :c
K_D            = :d
K_E            = :e
K_F            = :f
K_G            = :g
K_H            = :h
K_I            = :i
K_J            = :j
K_K            = :k
K_L            = :l
K_M            = :m
K_N            = :n
K_O            = :o
K_P            = :p
K_Q            = :q
K_R            = :r
K_S            = :s
K_T            = :t
K_U            = :u
K_V            = :v
K_W            = :w
K_X            = :x
K_Y            = :y
K_Z            = :z
K_DELETE       = :delete


# International keyboard symbols
K_WORLD_0  = :world_0
K_WORLD_1  = :world_1
K_WORLD_2  = :world_2
K_WORLD_3  = :world_3
K_WORLD_4  = :world_4
K_WORLD_5  = :world_5
K_WORLD_6  = :world_6
K_WORLD_7  = :world_7
K_WORLD_8  = :world_8
K_WORLD_9  = :world_9
K_WORLD_10 = :world_10
K_WORLD_11 = :world_11
K_WORLD_12 = :world_12
K_WORLD_13 = :world_13
K_WORLD_14 = :world_14
K_WORLD_15 = :world_15
K_WORLD_16 = :world_16
K_WORLD_17 = :world_17
K_WORLD_18 = :world_18
K_WORLD_19 = :world_19
K_WORLD_20 = :world_20
K_WORLD_21 = :world_21
K_WORLD_22 = :world_22
K_WORLD_23 = :world_23
K_WORLD_24 = :world_24
K_WORLD_25 = :world_25
K_WORLD_26 = :world_26
K_WORLD_27 = :world_27
K_WORLD_28 = :world_28
K_WORLD_29 = :world_29
K_WORLD_30 = :world_30
K_WORLD_31 = :world_31
K_WORLD_32 = :world_32
K_WORLD_33 = :world_33
K_WORLD_34 = :world_34
K_WORLD_35 = :world_35
K_WORLD_36 = :world_36
K_WORLD_37 = :world_37
K_WORLD_38 = :world_38
K_WORLD_39 = :world_39
K_WORLD_40 = :world_40
K_WORLD_41 = :world_41
K_WORLD_42 = :world_42
K_WORLD_43 = :world_43
K_WORLD_44 = :world_44
K_WORLD_45 = :world_45
K_WORLD_46 = :world_46
K_WORLD_47 = :world_47
K_WORLD_48 = :world_48
K_WORLD_49 = :world_49
K_WORLD_50 = :world_50
K_WORLD_51 = :world_51
K_WORLD_52 = :world_52
K_WORLD_53 = :world_53
K_WORLD_54 = :world_54
K_WORLD_55 = :world_55
K_WORLD_56 = :world_56
K_WORLD_57 = :world_57
K_WORLD_58 = :world_58
K_WORLD_59 = :world_59
K_WORLD_60 = :world_60
K_WORLD_61 = :world_61
K_WORLD_62 = :world_62
K_WORLD_63 = :world_63
K_WORLD_64 = :world_64
K_WORLD_65 = :world_65
K_WORLD_66 = :world_66
K_WORLD_67 = :world_67
K_WORLD_68 = :world_68
K_WORLD_69 = :world_69
K_WORLD_70 = :world_70
K_WORLD_71 = :world_71
K_WORLD_72 = :world_72
K_WORLD_73 = :world_73
K_WORLD_74 = :world_74
K_WORLD_75 = :world_75
K_WORLD_76 = :world_76
K_WORLD_77 = :world_77
K_WORLD_78 = :world_78
K_WORLD_79 = :world_79
K_WORLD_80 = :world_80
K_WORLD_81 = :world_81
K_WORLD_82 = :world_82
K_WORLD_83 = :world_83
K_WORLD_84 = :world_84
K_WORLD_85 = :world_85
K_WORLD_86 = :world_86
K_WORLD_87 = :world_87
K_WORLD_88 = :world_88
K_WORLD_89 = :world_89
K_WORLD_90 = :world_90
K_WORLD_91 = :world_91
K_WORLD_92 = :world_92
K_WORLD_93 = :world_93
K_WORLD_94 = :world_94
K_WORLD_95 = :world_95


# Numeric keypad symbols
K_KP0         = :keypad_0
K_KP1         = :keypad_1
K_KP2         = :keypad_2
K_KP3         = :keypad_3
K_KP4         = :keypad_4
K_KP5         = :keypad_5
K_KP6         = :keypad_6
K_KP7         = :keypad_7
K_KP8         = :keypad_8
K_KP9         = :keypad_9
K_KP_PERIOD   = :keypad_period
K_KP_DIVIDE   = :keypad_divide
K_KP_MULTIPLY = :keypad_multiply
K_KP_MINUS    = :keypad_minus
K_KP_PLUS     = :keypad_plus
K_KP_ENTER    = :keypad_enter
K_KP_EQUALS   = :keypad_equals


# Arrows + Home/End pad
K_UP       = :up
K_DOWN     = :down
K_RIGHT    = :right
K_LEFT     = :left
K_INSERT   = :insert
K_HOME     = :home
K_END      = :end
K_PAGEUP   = :pageup
K_PAGEDOWN = :pagedown


# Function keys
K_F1  = :f1
K_F2  = :f2
K_F3  = :f3
K_F4  = :f4
K_F5  = :f5
K_F6  = :f6
K_F7  = :f7
K_F8  = :f8
K_F9  = :f9
K_F10 = :f10
K_F11 = :f11
K_F12 = :f12
K_F13 = :f13
K_F14 = :f14
K_F15 = :f15


# Key state modifier keys
K_NUMLOCK   = :numlock
K_CAPSLOCK  = :capslock
K_SCROLLOCK = :scrollock
K_RSHIFT    = :right_shift
K_LSHIFT    = :left_shift
K_RCTRL     = :right_ctrl
K_LCTRL     = :left_ctrl
K_RALT      = :right_alt
K_LALT      = :left_alt
K_RMETA     = :right_meta
K_LMETA     = :left_meta
K_LSUPER    = :left_super
K_RSUPER    = :right_super
K_MODE      = :mode


# Miscellaneous keys
K_HELP   = :help
K_PRINT  = :print
K_SYSREQ = :sysreq
K_BREAK  = :break
K_MENU   = :menu
K_POWER  = :power
K_EURO   = :euro



# Mouse constants
MOUSE_LEFT   = :mouse_left
MOUSE_MIDDLE = :mouse_middle
MOUSE_RIGHT  = :mouse_right



# Joystick constants  
HAT_CENTERED  = nil
HAT_UP        = :up
HAT_RIGHT     = :right
HAT_DOWN      = :down
HAT_LEFT      = :left
HAT_RIGHTUP   = :up_right
HAT_RIGHTDOWN = :down_right
HAT_LEFTUP    = :up_left
HAT_LEFTDOWN  = :down_left
