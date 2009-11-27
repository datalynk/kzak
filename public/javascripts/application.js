function number_to_human_size(bytes) {
  var s = ['bytes', 'kb', 'MB', 'GB', 'TB', 'PB'];
  var e = Math.floor(Math.log(bytes)/Math.log(1024));
  return (bytes/Math.pow(1024, Math.floor(e))).toFixed(2)+" "+s[e];
}

$(document).ready(function(){
  
  var sm = soundManager;

  sm.url = '/flash';
  sm.debugMode = false;
  sm.useConsole = true;

  sm.onready(function() {
    $('a[href$=.mp3]').each(function() {
      $(this).makePlayable();
    });
  });

  $.fn.makePlayable = function() {
    $(this).addClass('playable');
    sm.createSound($(this)[0].id, $(this)[0].href);

    $(this).click(function(e) {
      e.preventDefault();
      $(this).playOne();
    });
  }

  $.fn.playOne = function() {
    if ($(this).hasClass('playing')) {
      $(this).removeClass('playing');
      $(this).addClass('paused');
      sm.pause($(this)[0].id);
      return;
    } if ($(this).hasClass('paused')) {
      $(this).removeClass('paused');
      $(this).addClass('playing');
      sm.resume($(this)[0].id);
      return;
    } else {
      sm.stopAll();
      $('a[href$=.mp3]').each(function() {
        $(this).resetPlayableStyles();
      });
      $(this).addClass('playing');
      sm.play($(this)[0].id);
      return;
    }
  }
  
  $.fn.resetPlayableStyles = function() {
    $(this).removeClass('playing');
    $(this).removeClass('paused');
  }
  
});

