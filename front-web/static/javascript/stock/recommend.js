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



document.addEventListener('DOMContentLoaded', () => {
  // 모달 띄우기
  const modal = document.querySelector('.modal');
  const modalOpens = document.querySelectorAll('.food');

  modalOpens.forEach(item => {
      item.addEventListener('click', function(event) {
          if (modal.classList.contains('on')) return;

          const expiration = this.querySelector('.expirationDate').textContent;
          const img = this.querySelector('.itemImg').textContent;
          const name = this.querySelector('.itemName').textContent;
          const count = this.querySelector('.countStocks').textContent;

          modal.querySelector('.count').textContent = count;
          modal.querySelector('.expirationDate-modal').textContent = expiration;
          modal.querySelector('.itemImg-modal').textContent = img;
          modal.querySelector('.itemName-modal').textContent = name;

          const expirationColor = window.getComputedStyle(this.querySelector('.expirationDate')).color;
          modal.querySelector('.expirationDate-modal').style.color = expirationColor;

          const countStocksColor = window.getComputedStyle(this.querySelector('.countStocks'));
          modal.querySelector('.countStocks-modal').style.backgroundColor = countStocksColor.backgroundColor;
          modal.querySelector('.countStocks-modal').style.border = countStocksColor.border;
          modal.querySelector('.countStocks-modal').style.color = countStocksColor.color;

          const bgColor = window.getComputedStyle(this).backgroundColor;
          const border = window.getComputedStyle(this).border;
          document.querySelector('.modalPopup').style.backgroundColor = bgColor;
          document.querySelector('.modalPopup').style.border = border;
          
          this.classList.add('on');
          modal.classList.add('on');
          document.body.classList.add('modal-open');

          event.stopPropagation();
      });
  });

  modal.querySelector('.modalPopup').addEventListener('click', function(event) {
      event.stopPropagation();
  });

  window.addEventListener('click', function(event) {
      if (modal.classList.contains('on') && !modal.querySelector('.modalPopup').contains(event.target)) {
          modal.classList.remove('on');
          document.body.classList.remove('modal-open');
          
          const openItem = document.querySelector('.itemList.on');
          if (openItem) {
              openItem.classList.remove('on');
          }
      }
  });
});