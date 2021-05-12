// Set cookie
function setCookie(name, value) {
  var date = new Date();
  date.setTime(date.getTime() + (24 * 3600 * 365 *1000));
  var expires = "expires=" + date.toUTCString();
  document.cookie = name + "=" + value + ";" + expires + ";path=/";
}

// Get cookie
function getCookie(name) {
  var name = name + "=";
  var ca = document.cookie.split(';');
  for(var i = 0 ; i < ca.length ; i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') {c = c.substring(1);}
    if (c.indexOf(name) == 0) {return c.substring(name.length, c.length);}
  }
  return "";
}

// Apply style sheet to document
function setStyleSheet(evt, style) {
  var i, a;
  for(i=0 ; (a = document.getElementsByClassName("style")[i]) ; i++) {
    if(a.getAttribute("rel").indexOf("style") != -1 && a.getAttribute("title")) {
      a.disabled = true;
      if(a.getAttribute("title") == style) a.disabled = false;
    }
  }
  // Set switch button colors
  document.getElementById('dark').style.background = "#e4e4e4";
  document.getElementById('dark').style.color = "#666666";
  document.getElementById('light').style.background = "#e4e4e4";
  document.getElementById('light').style.color = "#666666";
  document.getElementById(style).style.background = "#666666";
  document.getElementById(style).style.color = "white";
  setCookie("style", style);
}

// Display menu content
function displayMenu(evt, menuId) {
  var i, content_tab, tablinks;
  document.documentElement.scrollTop = 0;
  content_tab = document.getElementsByClassName("content_tab");
  for (i = 0; i < content_tab.length; i++) {
    content_tab[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0 ; i < tablinks.length ; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }
  document.getElementById(menuId).style.display = "block";
  evt.currentTarget.className += " active";
  setCookie("menuid", menuId);
}

// Get previous style from cookie
window.onload = function(e) {
  // load previous style
  var cookie_1 = getCookie("style");
  var style = cookie_1 ? cookie_1 : "dark";
  document.getElementById(style).click();
  // Load previous menu id
  var cookie_2 = getCookie("menuid");
  var menuId = cookie_2 ? cookie_2 : "Tools";
  menuId = "menu_" + menuId;
  document.getElementById(menuId).click();
}