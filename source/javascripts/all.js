//= require_tree .
(function($) {
  $(document).ready( function() {
    $('.e').emailLink();
    var header_pos =  $('.contacts').offset().top - 30;
    $(window).resize( function(){ $('.header-outer').css('height', '').css('height', $('.header-outer').outerHeight()); } ).resize();
    $(window).scroll(function(e){
      $('.header').toggleClass('fixed', ($(window).scrollTop() > header_pos));
    });
  } );
})(jQuery);
