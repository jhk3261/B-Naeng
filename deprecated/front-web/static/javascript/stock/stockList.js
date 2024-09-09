document.addEventListener('DOMContentLoaded', () => {
    const stockBoxes = document.querySelectorAll('.stockBox');

    stockBoxes.forEach(stockBox => {
        const slideLeft = stockBox.querySelector('.slideLeft');
        const slideRight = stockBox.querySelector('.slideRight');
        const stockListContainer = stockBox.querySelector('.stockListContainer > ul');

        let currentIndex = 0;
        const itemsPerPage = 4;
        const totalItems = stockListContainer.querySelectorAll('li').length;

        slideRight.addEventListener('click', () => {
            if (currentIndex < totalItems - itemsPerPage) {
                currentIndex += itemsPerPage;
                updateSlidePosition();
            }
        });

        slideLeft.addEventListener('click', () => {
            if (currentIndex > 0) {
                currentIndex -= itemsPerPage;
                updateSlidePosition();
            }
        });

        function updateSlidePosition() {
            const slideAmount = currentIndex * (164 + 20);
            stockListContainer.style.transform = `translateX(-${slideAmount}px)`;
        }
    });

    // 모달 띄우기
    const modal = document.querySelector('.modal');
    const modalOpens = document.querySelectorAll('.itemList');

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

    // 재고 수량 변경 부분
    const upBtn = modal.querySelector('.upBtn');
    const downBtn = modal.querySelector('.downBtn');
    const countElement = modal.querySelector('.count');

    // 재고 추가
    upBtn.addEventListener('click', function() {
        let currentCount = parseInt(countElement.textContent);
        currentCount += 1;
        countElement.textContent = currentCount;
        updateOriginalItemCount(currentCount); // 업뎃
    });

    // 재고 삭제
    downBtn.addEventListener('click', function() {
        let currentCount = parseInt(countElement.textContent);
        if (currentCount > 0) { 
            currentCount -= 1;
            countElement.textContent = currentCount;
            updateOriginalItemCount(currentCount); // 업뎃
        }
    });

    // html 값 수정 put 하는 부분
    function updateOriginalItemCount(newCount) {
        const originalItem = document.querySelector('.itemList.on .countStocks');
        if (originalItem) {
            originalItem.textContent = newCount;
        }
    }
});

// 뒤로가기
document.getElementById('moveBefore').addEventListener('click', function() {
    window.location.href = '/main';
});
