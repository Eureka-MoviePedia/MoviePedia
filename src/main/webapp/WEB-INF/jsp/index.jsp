<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MoviePedia</title>
    <!-- Google Fonts 링크는 여기에 위치 -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <!-- CSS 파일 링크 -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="icon" href="data:;base64,=">
</head>
<body>

<!-- 네비게이션 바 -->
<nav class="navbar">
    <div class="logo">
        <a href="/">
            <img src="${pageContext.request.contextPath}/images/logo.png" alt="MoviePedia 로고">
        </a>
    </div>
    <div class="search-bar">
        <input type="text" id="searchQuery" placeholder="콘텐츠, 인물, 컬렉션 검색">
        <button id="searchButton">검색</button>
    </div>
    <div class="user-options">
        <span id="user-nickname" style="display: none;"></span>
        <a href="/pages/register" id="register-link">회원가입</a>
        <a href="/pages/login" id="login-link">로그인</a>
        <a href="/pages/mypage" id="mypage-link" style="display: none;">마이페이지</a>
        <a href="#" id="logout-link" style="display: none;">로그아웃</a>
    </div>
</nav>

<!-- 박스오피스 순위 -->
<section class="box-office">
    <h2>박스오피스 순위</h2>
    <div class="box-office-grid" id="movieListContainer">
        <!-- 영화 카드들이 여기에 동적으로 추가됩니다 -->
    </div>
</section>

<!-- 개봉 예정작 섹션 -->
<section class="upcoming-section">
    <h2>공개 예정작</h2>
    <div class="upcoming-grid">
        <div class="upcoming-grid" id="upcomingListContainer">
            <!-- 개봉 예정 영화 카드들이 여기에 동적으로 추가됩니다 -->
        </div>
    </div>
</section>
<script>
    let LIST_ROW_COUNT = 10; // 한 페이지에 10개 로우
    let OFFSET = 0;

    window.onload = function () {
        checkLoginStatus();
        listMovie();
        listUpcomingMovies();

        document.getElementById('searchButton').addEventListener('click', function () {
            const query = document.getElementById('searchQuery').value;
            const page = 0;  // 첫 페이지로 설정
            const size = 10;  // 한 페이지에 10개의 결과 표시
            if (query) {
                // 검색 페이지로 이동
                window.location.href = `/pages/search?query=\${query}&page=\${page}&size=\${size}`;
            } else {
                alert('검색어를 입력해주세요.');
            }
        });
    }

    // 로그아웃 기능 추가
    document.getElementById('logout-link').addEventListener('click', function(e) {
        e.preventDefault();
        logout();
    });

    function checkLoginStatus() {
        const token = localStorage.getItem('token');
        const nickname = localStorage.getItem('nickname');
        updateUI(nickname);
    }

    function updateUI(nickname) {
        const userNicknameElement = document.getElementById('user-nickname');
        const registerLink = document.getElementById('register-link');
        const loginLink = document.getElementById('login-link');
        const logoutLink = document.getElementById('logout-link');
        const mypageLink = document.getElementById('mypage-link');

        if (nickname) {
            userNicknameElement.textContent = nickname;
            userNicknameElement.style.display = 'inline';
            registerLink.style.display = 'none';
            loginLink.style.display = 'none';
            logoutLink.style.display = 'inline';
            mypageLink.style.display = 'inline-block'; // 마이페이지 버튼 표시
        } else {
            userNicknameElement.style.display = 'none';
            registerLink.style.display = 'inline';
            loginLink.style.display = 'inline';
            logoutLink.style.display = 'none';
            mypageLink.style.display = 'none'; // 마이페이지 버튼 숨김
        }
    }

    function logout() {
        localStorage.removeItem('token');
        localStorage.removeItem('nickname');
        updateUI(null);
        window.location.href = '/';
    }

    async function listMovie() {
        const movieListContainer = document.getElementById('movieListContainer');
        movieListContainer.innerHTML = '<p>영화 데이터를 불러오는 중입니다...</p>';

        try {
            let fetchOptions = {
                headers: {
                    'ajax': 'true'
                }
            };

            let url = "/api/movies/rankings";
            let urlParams = "?page=" + OFFSET + "&size=" + LIST_ROW_COUNT;
            let response = await fetch(url + urlParams, fetchOptions);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            let data = await response.json();
            console.log("Received data:", data); // 데이터 로그 출력

            if (data.movieList && data.movieList.length > 0) {
                makeListHtml(data.movieList);
            } else {
                movieListContainer.innerHTML = '<p>표시할 영화 데이터가 없습니다.</p>';
            }
        } catch (error) {
            console.error("Error fetching movie data:", error);
            movieListContainer.innerHTML = `<p>영화 데이터를 불러오는 중 오류가 발생했습니다: ${error.message}</p>`;
        }
    }

    function makeListHtml(movieList) {
        const movieListContainer = document.getElementById('movieListContainer');
        movieListContainer.innerHTML = '';  // 먼저 기존 내용을 지우고
        const fragment = document.createDocumentFragment();  // Fragment 사용
        movieList.forEach((movie, index) => {
            console.log("Movie ID: ", movie.movieId);
            const movieCard = document.createElement('div');
            movieCard.classList.add('movie-card');

            movieCard.innerHTML = `
            <a href="/pages/movies/\${movie.movieId}">
                <img src="\${movie.imageUrl}" alt="\${movie.title} 포스터">
            </a>
            <div class="rank">\${index + 1}</div>
            <div class="title">\${movie.title}</div>
            <div class="reservationRate">예매율: \${movie.reservationRate}%</div>
        `;
            fragment.appendChild(movieCard);  // Fragment에 추가
        });
        movieListContainer.appendChild(fragment);  // 마지막에 한 번에 추가
    }

    // 로그아웃 기능 추가
    document.getElementById('logout-link').addEventListener('click', function(e) {
        checkLoginStatus();
        e.preventDefault();
        localStorage.removeItem('token');
        localStorage.removeItem('nickname');
        updateUI(null);
        window.location.href = '/';  // 홈페이지로 리디렉션
    });

    // 개봉 예정작 가져오기
    async function listUpcomingMovies() {
        const upcomingListContainer = document.getElementById('upcomingListContainer');
        upcomingListContainer.innerHTML = '<p>개봉 예정 영화를 불러오는 중입니다...</p>';

        try {
            let fetchOptions = {
                headers: {
                    'ajax': 'true'
                }
            };

            let url = "/api/movies/upcoming";
            let urlParams = "?page=" + OFFSET + "&size=" + LIST_ROW_COUNT;
            let response = await fetch(url + urlParams, fetchOptions);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            let data = await response.json();
            console.log("Received upcoming movies:", data); // 데이터 로그 출력

            if (data.movieList && data.movieList.length > 0) {
                makeUpcomingListHtml(data.movieList);
            } else {
                upcomingListContainer.innerHTML = '<p>표시할 개봉 예정 영화가 없습니다.</p>';
            }
        } catch (error) {
            console.error("Error fetching upcoming movie data:", error);
            upcomingListContainer.innerHTML = `<p>개봉 예정 영화를 불러오는 중 오류가 발생했습니다: ${error.message}</p>`;
        }
    }

    function makeUpcomingListHtml(movieList) {
        const upcomingListContainer = document.getElementById('upcomingListContainer');
        upcomingListContainer.innerHTML = '';  // 먼저 기존 내용을 지우고
        const fragment = document.createDocumentFragment();  // Fragment 사용
        movieList.forEach(movie => {
            const movieCard = document.createElement('div');
            movieCard.classList.add('upcoming-card');

            movieCard.innerHTML = `
            <a href="/pages/movies/\${movie.movieId}">
                <img src="\${movie.imageUrl}" alt="\${movie.title} 포스터">
            </a>
            <div class="release-date">\${movie.releaseDate}</div>
            <div class="title">\${movie.title}</div>
        `;
            fragment.appendChild(movieCard);  // Fragment에 추가
        });
        upcomingListContainer.appendChild(fragment);  // 마지막에 한 번에 추가
    }
</script>

</body>
</html>
