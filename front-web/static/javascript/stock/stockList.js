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
});



document.addEventListener('DOMContentLoaded', function() {
    const modal = document.querySelector('.modal');
    const modalOpens = document.querySelectorAll('.itemList');

    modalOpens.forEach(item => {
        item.addEventListener('click', function(event) {
            if (modal.classList.contains('on')) return;

            const expiration = this.querySelector('.expirationDate').textContent;
            const img = this.querySelector('.itemImg').textContent;
            const name = this.querySelector('.itemName').textContent;
            const count = this.querySelector('.countStocks').textContent;

            modal.querySelector('.countStocks-modal').textContent = count;
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

        }
    });
});
