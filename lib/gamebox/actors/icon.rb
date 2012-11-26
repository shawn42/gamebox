# actor to represent an image being drawn somewhere
# example:
#  create_actor :icon, image: 'my/image.png'
define_actor :icon do
  has_behaviors :positioned, :graphical
  has_attributes view: :graphical_actor_view
end
