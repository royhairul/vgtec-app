// Configuration - Update this with your GitHub repository details
const CONFIG = {
    owner: 'royhairul', // Replace with your GitHub username
    repo: 'vgtec-app',  // Replace with your repository name
};

// DOM Elements
const heroVersion = document.getElementById('hero-version');
const downloadVersion = document.getElementById('download-version');
const versionTag = document.getElementById('version-tag');
const releaseDate = document.getElementById('release-date');
const downloadBtn = document.getElementById('download-btn');
const fileSize = document.getElementById('file-size');
const fileSizeText = document.getElementById('file-size-text');
const fileSizeBadge = document.getElementById('file-size-badge');
const releasesList = document.getElementById('releases-list');

// Fetch all releases from GitHub API
async function fetchReleases() {
    try {
        const response = await fetch(
            `https://api.github.com/repos/${CONFIG.owner}/${CONFIG.repo}/releases`
        );

        if (!response.ok) {
            throw new Error('Releases not found');
        }

        const releases = await response.json();
        return releases;
    } catch (error) {
        console.error('Error fetching releases:', error);
        return null;
    }
}

// Find APK asset from release
function findApkAsset(release) {
    if (!release || !release.assets) return null;

    return release.assets.find(asset =>
        asset.name.toLowerCase().endsWith('.apk')
    );
}

// Format date to Indonesian locale
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Format file size
function formatFileSize(bytes) {
    if (!bytes) return '';
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

// Update hero section with latest release info
function updateHeroSection(release) {
    if (!release) {
        if (heroVersion) heroVersion.textContent = '';
        return;
    }

    if (heroVersion) {
        heroVersion.textContent = release.tag_name;
    }
}

// Update download section with latest release info
function updateDownloadSection(release) {
    if (!release) {
        if (downloadVersion) downloadVersion.textContent = '--';
        if (releaseDate) releaseDate.textContent = 'Belum ada release tersedia';
        if (downloadBtn) {
            downloadBtn.href = `https://github.com/${CONFIG.owner}/${CONFIG.repo}/releases`;
        }
        return;
    }

    const apkAsset = findApkAsset(release);

    if (downloadVersion) {
        downloadVersion.textContent = release.tag_name;
    }

    if (versionTag) {
        versionTag.textContent = 'Latest';
    }

    if (releaseDate) {
        releaseDate.textContent = `Dirilis ${formatDate(release.published_at)}`;
    }

    if (downloadBtn) {
        if (apkAsset) {
            downloadBtn.href = apkAsset.browser_download_url;
        } else {
            downloadBtn.href = release.html_url;
        }
    }

    // Update file size elements
    if (apkAsset) {
        const sizeFormatted = formatFileSize(apkAsset.size);
        if (fileSize) fileSize.textContent = `• ${sizeFormatted}`;
        if (fileSizeText) fileSizeText.textContent = `Ukuran: ${sizeFormatted}`;
        if (fileSizeBadge) fileSizeBadge.textContent = sizeFormatted;
    }
}

// Render releases list
function renderReleases(releases) {
    if (!releasesList) return;

    if (!releases || releases.length === 0) {
        releasesList.innerHTML = `
            <div class="no-releases">
                <p>Belum ada release yang tersedia.</p>
                <p>Silakan cek kembali nanti.</p>
            </div>
        `;
        return;
    }

    let html = '';

    releases.forEach((release, index) => {
        const apkAsset = findApkAsset(release);
        const isLatest = index === 0;

        html += `
            <div class="release-item ${isLatest ? 'latest' : ''}">
                <div class="release-header">
                    <span class="release-version">${release.tag_name}</span>
                    ${isLatest ? '<span class="release-tag">Latest</span>' : ''}
                </div>
                <p class="release-date-text">${formatDate(release.published_at)}</p>
                ${apkAsset ? `
                    <a href="${apkAsset.browser_download_url}" class="release-download">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                        Download APK ${formatFileSize(apkAsset.size) ? `(${formatFileSize(apkAsset.size)})` : ''}
                    </a>
                ` : `
                    <a href="${release.html_url}" class="release-download" target="_blank" rel="noopener noreferrer">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                        Lihat di GitHub
                    </a>
                `}
            </div>
        `;
    });

    releasesList.innerHTML = html;
}

// Initialize the page
async function init() {
    const releases = await fetchReleases();

    if (releases && releases.length > 0) {
        const latestRelease = releases[0];
        updateHeroSection(latestRelease);
        updateDownloadSection(latestRelease);
        renderReleases(releases);
    } else {
        updateHeroSection(null);
        updateDownloadSection(null);
        renderReleases(null);
    }
}

// Navbar scroll effect
function handleNavbarScroll() {
    const navbar = document.getElementById('navbar');
    if (!navbar) return;

    if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
        navbar.style.boxShadow = '0 1px 3px rgba(0, 0, 0, 0.08), 0 1px 2px rgba(0, 0, 0, 0.06)';
        navbar.style.background = 'rgba(255, 255, 255, 0.98)';
    } else {
        navbar.classList.remove('scrolled');
        navbar.style.boxShadow = 'none';
        navbar.style.background = '#FFFFFF';
    }
}

// Smooth scroll for anchor links
function handleAnchorClicks() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Event listeners
window.addEventListener('scroll', handleNavbarScroll);
document.addEventListener('DOMContentLoaded', () => {
    init();
    handleAnchorClicks();
});
