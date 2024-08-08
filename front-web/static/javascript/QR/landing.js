const REFRIGERATOR_ID = 2422;
let intervalId;
let SERVER_ADDRESS = location.host;

const createAndShowQRCode = () => {
  let QR_background = document.getElementsByClassName("QR_background")[0];
  let qrCode = new QRCode(QR_background, {
    text: `http://${SERVER_ADDRESS}/api/QRLogin/${REFRIGERATOR_ID}`,
    width: 500,
    height: 500,
    colorDark: "#000000",
    colorLight: "rgba(0,0,0,0)", // 투명 배경 설정
    correctLevel: QRCode.CorrectLevel.H,
  });

  let canvas = QR_background.querySelector("canvas");
  let ctx = canvas.getContext("2d");
  let imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
  let data = imageData.data;

  for (let i = 0; i < data.length; i += 4) {
    if (data[i] === 255 && data[i + 1] === 255 && data[i + 2] === 255) {
      data[i + 3] = 0;
    }
  }

  ctx.putImageData(imageData, 0, 0);
};

const checkLoginCondition = () => {
  let timer = document.getElementsByClassName("header_timer")[0];
  let now = new Date();
  let hours = now.getHours().toString().padStart(2, "0");
  let minutes = now.getMinutes().toString().padStart(2, "0");
  let seconds = now.getSeconds().toString().padStart(2, "0");
  timer.innerHTML = `${hours}:${minutes}:${seconds}`;

  fetch("/api/checkCondition")
    .then((response) => response.json())
    .then((data) => {
      if (data.condition) {
        clearInterval(intervalId);

        let QR_background = document.getElementsByClassName("QR_background")[0];
        QR_background.innerHTML = `
        <div class="loading">
        <div class="loader loader-6"></div>
        </div>
        `;
        QR_background.style.backgroundColor = "rgba(0, 0, 0, 0)";

        setTimeout(() => {
          location.href = "/main";
        }, 5000);
      }
    });
};

createAndShowQRCode();
intervalId = setInterval(checkLoginCondition, 1000);
