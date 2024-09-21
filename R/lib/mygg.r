#
# Own ggsave function to reduce lines of code 
#

myggsave <- function( file, plot, scale = 1, width = 1920, height = 1080, dpi = 144) {
  
  ggsave(  file = file
           , plot = plot
           , bg = "white"
           , width = width * scale
           , height = height * scale
           , units = "px"
           , dpi = dpi )
  
}