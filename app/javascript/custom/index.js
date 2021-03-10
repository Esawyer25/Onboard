console.log("hello from index")

$(document).ready(function() {
    clockUpdate();
    setInterval(clockUpdate, 1000);
  })

  function clockUpdate() {
      console.log("updating")
    var date = new Date();
    function addZero(x) {
      if (x < 10) {
        return x = '0' + x;
      } else {
        return x;
      }
    }

    function twelveHour(x) {
      if (x > 12) {
        return x = x - 12;
      } else if (x == 0) {
        return x = 12;
      } else {
        return x;
      }
    }

    var d = date.getDate();
    var h = addZero(twelveHour(date.getHours()));
    var m = addZero(date.getMinutes());
    var s = addZero(date.getSeconds());

    $('.digital-clock').text("March " + d + " " + h + ':' + m + ':' + s)
  }

$(function () {
    $('.start').click(function () {
        var $this = $(this);
        var member_id = $this.attr('id');
        var params = {}
        params["member_id"] = member_id;
        $.post('edit/start_shift', params, function(){
        });
        var current = new Date().toLocaleString('en-US', { timeZone: 'America/New_York' });
        // toggel buttons
        $this.attr("disabled", true);;
        $(`.end${member_id}`).removeAttr("disabled");
        $(`.break_start${member_id}`).removeAttr("disabled");

        $(`.update_${member_id}`).append(`<br>Day Start: ${current}`)
    })
})

$(function () {
    $('.break_start').click(function () {
        var $this = $(this);
        var member_id = $this.attr('id');
        var params = {}
        var current = new Date().toLocaleString('en-US', { timeZone: 'America/New_York' });
        params["member_id"] = member_id;
        $.post('edit/break_start', params, function(){
        });

        // toggel buttons
        $this.attr("disabled", true);
        $(`.break_end${member_id}`).attr("disabled", false);
        $(`.update_${member_id}`).append(`<br>Lunch Start: ${current}`)
    })
})

$(function () {
    $('.break_end').click(function () {
        console.log("in break end")
        var $this = $(this);
        var member_id = $this.attr('id');
        var params = {}
        var current = new Date().toLocaleString('en-US', { timeZone: 'America/New_York' });
        params["member_id"] = member_id;
        $.post('edit/break_end', params, function(){
        });

        // toggel buttons
        $this.attr("disabled", true);
        $(`.update_${member_id}`).append(`<br>Lunch End: ${current}`)
    })
})

$(function () {
    $('.end').click(function () {
        var $this = $(this);
        var member_id = $this.attr('id');
        var params = {}
        params["member_id"] = member_id;
        var current = new Date().toLocaleString('en-US', { timeZone: 'America/New_York' });
        $.post('edit/stop_shift', params, function(){
        });

        // toggel buttons
        $this.attr("disabled", true);
        $(`.start${member_id}`).attr("disabled", false);
        $(`.break_start${member_id}`).attr("disabled", true);
        $(`.update_${member_id}`).append(`<br>Day End: ${current}<br>`);
    })
})




