var swiper = new Swiper(".mySwiper", {
  slidesPerView: 1,
  spaceBetween: 10,
  centeredSlides: false,
  grid: {
    rows: 1,
  },
  // pagination: {
  //   el: ".swiper-pagination",
  //   clickable: true,
  // },
  breakpoints: {
    1024: {
      slidesPerView: 3,
      spaceBetween: 50,
    },
  },
});

var swiper = new Swiper(".mySwiper2", {
  slidesPerView: 1,
  spaceBetween: 10,
  centeredSlides: false,
  grid: {
    rows: 1,
  },

    pagination: {
      el: ".swiper-pagination2",
      clickable: true,
    },
    breakpoints: {
      1024: {
        slidesPerView: 3,
        spaceBetween: 50,
      },
    },
  });

const TimerCode = () => {
    let timer = document.getElementsByClassName("header_timer")[0];
    let now = new Date();
    let hours = now.getHours().toString().padStart(2, "0");
    let minutes = now.getMinutes().toString().padStart(2, "0");
    let seconds = now.getSeconds().toString().padStart(2, "0");
    timer.innerHTML = `${hours}:${minutes}:${seconds}`;
}

TimerCode();
setInterval(TimerCode, 1000); //매초에 한번씩 실행