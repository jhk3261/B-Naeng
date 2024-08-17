let btn1 = document.getElementsByClassName("btn1")[0];
let btn2 = document.getElementsByClassName("btn2")[0];

// 재고 관리 버튼
btn1.addEventListener('click',  () => {
  location.href = "/stock_list"
})

btn2.addEventListener('click',  () => {
  location.href = "/recommend"
})