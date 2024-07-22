function getCookie(cookieName) {
  cookieName = `${cookieName}=`;
  let cookieData = document.cookie;

  let cookieValue = "";
  let start = cookieData.indexOf(cookieName);

  if (start !== -1) {
    start += cookieName.length;
    let end = cookieData.indexOf(";", start);
    if (end === -1) end = cookieData.length;
    cookieValue = cookieData.substring(start, end);
  }

  return cookieValue;
}

function removeCookie(cookieName) {
  // Set the cookie with an expired date
  document.cookie = `${cookieName}=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/`;
}

if (getCookie("welcome_new_user") == "True") {
  alert("회원가입이 완료되어 홈 화면으로 이동합니다.");
  removeCookie("welcome_new_user");
}
