var swiper = new Swiper(".mySwiper", {
    spaceBetween: 30,

    pagination: {
      el: ".swiper-pagination",
      clickable: true,
    },
  });

const TimerCode = () => {
    let timer = document.getElementsByClassName("header_timer")[0];
    let now = new Date();
    let hours = now.getHours()
    let minutes = now.getMinutes()
    let seconds = now.getSeconds()
    timer.innerHTML = `${hours}:${minutes}:${seconds}`;
}

TimerCode();
setInterval(TimerCode, 1000); //매초에 한번씩 실행