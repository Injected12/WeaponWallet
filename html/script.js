// Global variables
let config = {
    backgroundColor: "rgba(0, 0, 0, 0.8)",
    textColor: "#FFFFFF",
    accentColor: "#ff9f1c",
    errorColor: "#e63946",
    successColor: "#2a9d8f",
    fontSize: "1rem",
    borderRadius: "5px"
};

let weapons = {};
let categories = [];
let currentCategory = null;
let currentWeapon = null;
let isLoggedIn = false;
let username = null;
let userData = null;

// Helper functions
function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.add('hidden');
    });
    document.getElementById(screenId).classList.remove('hidden');
    document.getElementById('main-container').classList.remove('hidden');
}

function hideAllScreens() {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.add('hidden');
    });
    document.getElementById('main-container').classList.add('hidden');
}

function showNotification(message, type = 'info', duration = 3000) {
    const notificationsContainer = document.getElementById('notifications-container');
    
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    // Create progress bar
    const progressBar = document.createElement('div');
    progressBar.className = 'notification-progress';
    notification.appendChild(progressBar);
    
    // Add to container
    notificationsContainer.appendChild(notification);
    
    // Show notification (slight delay for animation)
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // Animate progress bar
    progressBar.style.animation = `shrink ${duration}ms linear forwards`;
    
    // Remove after duration
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, duration);
}

function formatWeaponName(weaponName) {
    // Remove WEAPON_ prefix
    weaponName = weaponName.replace('WEAPON_', '');
    
    // Convert to title case and add spaces
    return weaponName
        .toLowerCase()
        .replace(/(_|-)/g, ' ')
        .replace(/\b\w/g, c => c.toUpperCase());
}

function populateCategories() {
    const categoriesList = document.getElementById('categories-list');
    categoriesList.innerHTML = '';
    
    categories.forEach(category => {
        const li = document.createElement('li');
        li.textContent = category;
        li.dataset.category = category;
        li.addEventListener('click', () => {
            selectCategory(category);
        });
        categoriesList.appendChild(li);
    });
    
    // Auto-select first category
    if (categories.length > 0) {
        selectCategory(categories[0]);
    }
}

function selectCategory(category) {
    currentCategory = category;
    
    // Update UI
    document.querySelectorAll('#categories-list li').forEach(li => {
        li.classList.remove('active');
        if (li.dataset.category === category) {
            li.classList.add('active');
        }
    });
    
    // Populate weapons for this category
    populateWeapons(category);
}

function populateWeapons(category) {
    const weaponsList = document.getElementById('weapons-list');
    weaponsList.innerHTML = '';
    
    // Filter weapons by category
    const categoryWeapons = Object.entries(weapons).filter(([weaponName, price]) => {
        // Simple categorization based on weapon name
        if (category === 'Handguns' && (weaponName.includes('PISTOL') || weaponName.includes('REVOLVER'))) {
            return true;
        } else if (category === 'Submachine Guns' && (weaponName.includes('SMG') || weaponName.includes('MACHINEPISTOL'))) {
            return true;
        } else if (category === 'Shotguns' && weaponName.includes('SHOTGUN')) {
            return true;
        } else if (category === 'Assault Rifles' && (weaponName.includes('RIFLE') && !weaponName.includes('SNIPER'))) {
            return true;
        } else if (category === 'Sniper Rifles' && (weaponName.includes('SNIPER') || weaponName.includes('MARKSMAN'))) {
            return true;
        } else if (category === 'Heavy Weapons' && (weaponName.includes('MG') || weaponName.includes('MINIGUN') || weaponName.includes('RPG') || weaponName.includes('GRENADE_LAUNCHER'))) {
            return true;
        } else if (category === 'Melee Weapons' && (weaponName.includes('KNIFE') || weaponName.includes('BAT') || weaponName.includes('BOTTLE') || weaponName.includes('CROWBAR') || weaponName.includes('HAMMER') || weaponName.includes('HATCHET') || weaponName.includes('MACHETE'))) {
            return true;
        } else if (category === 'Thrown Weapons' && (weaponName.includes('GRENADE') || weaponName.includes('MOLOTOV') || weaponName.includes('STICKY_BOMB') || weaponName.includes('PIPE_BOMB'))) {
            return true;
        }
        return false;
    });
    
    if (categoryWeapons.length === 0) {
        const li = document.createElement('li');
        li.textContent = 'No weapons available in this category';
        li.style.color = 'rgba(255, 255, 255, 0.5)';
        li.style.fontStyle = 'italic';
        li.style.cursor = 'default';
        weaponsList.appendChild(li);
    } else {
        categoryWeapons.forEach(([weaponName, price]) => {
            const li = document.createElement('li');
            li.dataset.weapon = weaponName;
            
            const nameSpan = document.createElement('span');
            nameSpan.textContent = formatWeaponName(weaponName);
            li.appendChild(nameSpan);
            
            const priceSpan = document.createElement('span');
            priceSpan.className = 'weapon-price';
            priceSpan.textContent = '$' + price;
            li.appendChild(priceSpan);
            
            li.addEventListener('click', () => {
                selectWeapon(weaponName, price);
            });
            
            weaponsList.appendChild(li);
        });
    }
    
    // Reset weapon details
    resetWeaponDetails();
}

function selectWeapon(weaponName, price) {
    currentWeapon = { name: weaponName, price: price };
    
    // Update UI
    document.querySelectorAll('#weapons-list li').forEach(li => {
        li.classList.remove('active');
        if (li.dataset.weapon === weaponName) {
            li.classList.add('active');
        }
    });
    
    // Update weapon details
    updateWeaponDetails(weaponName, price);
}

function updateWeaponDetails(weaponName, price) {
    const detailsContainer = document.getElementById('weapon-details-content');
    detailsContainer.innerHTML = '';
    
    const header = document.createElement('div');
    header.className = 'weapon-detail-header';
    
    const name = document.createElement('h2');
    name.textContent = formatWeaponName(weaponName);
    header.appendChild(name);
    
    const priceElement = document.createElement('p');
    priceElement.textContent = '$' + price;
    header.appendChild(priceElement);
    
    detailsContainer.appendChild(header);
    
    // Add some fictitious details about the weapon
    const details = document.createElement('div');
    details.className = 'weapon-detail-info';
    
    const descriptionTitle = document.createElement('h3');
    descriptionTitle.textContent = 'Description';
    details.appendChild(descriptionTitle);
    
    const description = document.createElement('p');
    description.textContent = 'This imported weapon is available for purchase. Price includes delivery.';
    description.style.marginBottom = '20px';
    details.appendChild(description);
    
    detailsContainer.appendChild(details);
    
    // Add purchase button
    const actions = document.createElement('div');
    actions.className = 'weapon-detail-actions';
    
    const purchaseBtn = document.createElement('button');
    purchaseBtn.className = 'btn btn-success';
    purchaseBtn.textContent = 'Purchase Weapon';
    purchaseBtn.addEventListener('click', () => {
        purchaseWeapon(weaponName, price);
    });
    
    actions.appendChild(purchaseBtn);
    detailsContainer.appendChild(actions);
}

function resetWeaponDetails() {
    currentWeapon = null;
    const detailsContainer = document.getElementById('weapon-details-content');
    detailsContainer.innerHTML = '<p class="select-prompt">Select a weapon to view details</p>';
}

function purchaseWeapon(weaponName, price) {
    $.post('https://weapons_shop/purchaseWeapon', JSON.stringify({
        weapon: weaponName,
        price: price
    }));
}

function login(username, password) {
    $.post('https://weapons_shop/login', JSON.stringify({
        username: username,
        password: password
    }));
}

function logout() {
    isLoggedIn = false;
    username = null;
    userData = null;
    weapons = {};
    
    $.post('https://weapons_shop/logout', JSON.stringify({}));
    
    showScreen('login-screen');
}

function closeMenu() {
    $.post('https://weapons_shop/closeMenu', JSON.stringify({}));
    hideAllScreens();
}

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
    // Login button
    document.getElementById('login-btn').addEventListener('click', function() {
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value.trim();
        
        if (username === '' || password === '') {
            showNotification('Please enter both username and password', 'error');
            return;
        }
        
        login(username, password);
    });
    
    // Close login button
    document.getElementById('close-login-btn').addEventListener('click', function() {
        closeMenu();
    });
    
    // Close shop button
    document.getElementById('close-shop-btn').addEventListener('click', function() {
        closeMenu();
    });
    
    // Logout button
    document.getElementById('logout-btn').addEventListener('click', function() {
        logout();
    });
    
    // Handle keydown
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeMenu();
        }
    });
});

// NUI message handler
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'openMenu') {
        // Set config
        if (data.config) {
            config = data.config;
            applyConfig();
        }
        
        // Set categories
        if (data.categories) {
            categories = data.categories;
        }
        
        if (isLoggedIn) {
            showScreen('shop-screen');
            populateCategories();
        } else {
            showScreen('login-screen');
        }
    } else if (data.type === 'closeMenu') {
        hideAllScreens();
    } else if (data.type === 'loginSuccess') {
        isLoggedIn = true;
        username = data.username;
        userData = {
            name: data.name
        };
        weapons = data.weapons;
        
        // Update UI
        document.getElementById('user-name').textContent = userData.name;
        
        // Reset form
        document.getElementById('username').value = '';
        document.getElementById('password').value = '';
        
        // Show shop screen
        showScreen('shop-screen');
        populateCategories();
    } else if (data.type === 'loginFailure') {
        showNotification('Invalid username or password', 'error');
    } else if (data.type === 'purchaseSuccess') {
        // Just show notification, no need to do anything else
    } else if (data.type === 'purchaseFailure') {
        showNotification(data.message, 'error');
    } else if (data.type === 'notification') {
        showNotification(data.message, data.notificationType);
    }
});

// Apply config to styles
function applyConfig() {
    const style = document.createElement('style');
    style.textContent = `
        #main-container {
            background-color: ${config.backgroundColor};
            color: ${config.textColor};
            border-radius: ${config.borderRadius};
        }
        .btn-primary {
            background-color: ${config.accentColor};
        }
        .btn-primary:hover {
            background-color: ${darkenColor(config.accentColor, 10)};
        }
        .logo h1, .shop-header h1 {
            color: ${config.accentColor};
        }
        .logo i {
            color: ${config.accentColor};
        }
        .notification.error {
            background-color: ${config.errorColor};
        }
        .notification.success {
            background-color: ${config.successColor};
        }
        .weapon-price {
            color: ${config.accentColor};
        }
        .weapon-detail-header h2 {
            color: ${config.accentColor};
        }
        #categories-list li.active {
            background-color: ${hexToRgba(config.accentColor, 0.3)};
            color: ${config.accentColor};
        }
    `;
    document.head.appendChild(style);
}

// Helper to darken a hex color
function darkenColor(hex, percent) {
    hex = hex.replace(/^\s*#|\s*$/g, '');
    
    // Convert to RGB
    let r = parseInt(hex.substr(0, 2), 16);
    let g = parseInt(hex.substr(2, 2), 16);
    let b = parseInt(hex.substr(4, 2), 16);
    
    // Darken
    r = Math.floor(r * (100 - percent) / 100);
    g = Math.floor(g * (100 - percent) / 100);
    b = Math.floor(b * (100 - percent) / 100);
    
    // Convert back to hex
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
}

// Helper to convert hex to rgba
function hexToRgba(hex, opacity) {
    hex = hex.replace(/^\s*#|\s*$/g, '');
    
    // Convert to RGB
    let r = parseInt(hex.substr(0, 2), 16);
    let g = parseInt(hex.substr(2, 2), 16);
    let b = parseInt(hex.substr(4, 2), 16);
    
    return `rgba(${r}, ${g}, ${b}, ${opacity})`;
}

// jQuery-like $ function for simpler API posts
const $ = {
    post: function(url, data, callback) {
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: data
        })
        .then(response => response.json())
        .then(data => {
            if (callback) callback(data);
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }
};
