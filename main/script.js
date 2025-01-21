let map;
let allLocations = [];
let displayedCount = 0; // Number of locations already displayed
let markers = [];

// Initialize the Google Map
function initMap() {
  map = new google.maps.Map(document.getElementById("map"), {
    center: { lat: 40.916, lng: -74.17 }, // Default coordinates (e.g., New Jersey)
    zoom: 12,
  });
}

// Function to get the user's location or use the default map center
function getUserLocation() {
  return new Promise((resolve) => {
    const locationAsked = sessionStorage.getItem("locationAsked");

    // Check if user was already asked for location
    if (locationAsked) {
      // Try to get the user's location
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (position) => resolve({
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          }),
          () => resolve(map.getCenter().toJSON()) // If denied, fallback to default map center
        );
      } else {
        resolve(map.getCenter().toJSON()); // Geolocation not supported
      }
      return;
    }

    // Ask the user for permission to access their location
    const askForLocation = confirm("Would you like to share your location for better search results?");

    if (askForLocation) {
      sessionStorage.setItem("locationAsked", "true"); // Mark as asked
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (position) => resolve({
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          }),
          () => resolve(map.getCenter().toJSON()) // If denied, fallback to default map center
        );
      } else {
        resolve(map.getCenter().toJSON()); // Geolocation not supported
      }
    } else {
      resolve(map.getCenter().toJSON()); // Fallback to default if user refuses
    }
  });
}

// Function to fetch and load locations based on the search input
async function loadLocations(searchTerm = "") {
  if (!searchTerm) {
    return; // Do not fetch or display anything without a search term
  }

  const userLocation = await getUserLocation(); // Get user location
  const maxDistance = parseFloat(document.getElementById("distance-filter").value);

  const url = `getLocationData.cfm?searchTerm=${encodeURIComponent(searchTerm)}`;

  fetch(url)
    .then((response) => response.json())
    .then((locations) => {
      // Create a Map to track unique locations
      const uniqueLocations = new Map();

      // Loop through the fetched locations and use a composite key to identify duplicates
      locations.forEach(location => {
        const key = `${location.loc_name}-${location.loc_admin_street1}-${location.loc_admin_city}-${location.loc_admin_state}-${location.loc_admin_zip}`;

        if (!uniqueLocations.has(key)) {
          uniqueLocations.set(key, location);
        }
      });

      // Convert Map back to array
      const uniqueLocationsArray = Array.from(uniqueLocations.values());

      // Filter based on the max distance if specified
      allLocations = maxDistance
        ? uniqueLocationsArray.filter((location) =>
            calculateDistanceInMiles(userLocation, {
              lat: parseFloat(location.latitude),
              lng: parseFloat(location.longitude),
            }) <= maxDistance
          )
        : uniqueLocationsArray;

      displayedCount = 0; // Reset displayed count
      clearExistingLocations();
      displayLocations();
    })
    .catch((error) => console.error("Error fetching locations:", error));
}

// Clear existing locations and markers
function clearExistingLocations() {
  const locationList = document.getElementById("location-list");
  locationList.innerHTML = ""; // Clear the list

  markers.forEach((marker) => marker.setMap(null)); // Remove all markers from the map
  markers = []; // Reset markers array
}

// Display a subset of locations and add markers to the map
function displayLocations() {
  const locationList = document.getElementById("location-list");

  const locationsToShow = allLocations.slice(displayedCount, displayedCount + 5);
  displayedCount += locationsToShow.length;

  locationsToShow.forEach((location) => {
    const locationItem = document.createElement("div");
    locationItem.classList.add("location-item");

    locationItem.innerHTML = `
      <h3>${location.loc_name}</h3>
      <p>Address: ${location.loc_admin_street1}, ${location.loc_admin_city}, ${location.loc_admin_state}, ${location.loc_admin_zip}</p>
      <p>Phone: ${location.loc_phone}</p>
      <p><strong>Hours:</strong></p>
      <ul>
        <li>Sunday: ${location.sunday_hours}</li>
        <li>Monday: ${location.monday_hours}</li>
        <li>Tuesday: ${location.tuesday_hours}</li>
        <li>Wednesday: ${location.wednesday_hours}</li>
        <li>Thursday: ${location.thursday_hours}</li>
        <li>Friday: ${location.friday_hours}</li>
        <li>Saturday: ${location.saturday_hours}</li>
      </ul>
      <p><strong>In Stock:</strong> ${location.in_stock ? "Yes" : "No"}</p>
      <a href="${location.web_address}" target="_blank">Visit Website</a>
    `;

    locationList.appendChild(locationItem);

    const marker = new google.maps.Marker({
      position: { lat: parseFloat(location.latitude), lng: parseFloat(location.longitude) },
      map: map,
      title: location.loc_name,
    });
    markers.push(marker);

    const infoWindow = new google.maps.InfoWindow({
      content: `
        <h3>${location.loc_name}</h3>
        <p>Address: ${location.loc_admin_street1}, ${location.loc_admin_city}, ${location.loc_admin_state}, ${location.loc_admin_zip}</p>
        <p>Phone: ${location.loc_phone}</p>
      `,
    });

    marker.addListener("click", () => {
      infoWindow.open(map, marker);
    });
  });
}

// Infinite scrolling implementation
function setupInfiniteScroll() {
  window.addEventListener("scroll", () => {
    if (
      window.innerHeight + window.scrollY >= document.body.offsetHeight - 100 &&
      displayedCount < allLocations.length
    ) {
      displayLocations();
    }
  });
}

// Function to calculate the distance between two lat/lng points in miles
function calculateDistanceInMiles(point1, point2) {
  const R = 3958.8; // Radius of the Earth in miles
  const dLat = (point2.lat - point1.lat) * (Math.PI / 180);
  const dLon = (point2.lng - point1.lng) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(point1.lat * (Math.PI / 180)) * Math.cos(point2.lat * (Math.PI / 180)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Search functionality
function searchLocation() {
  const searchTerm = document.getElementById("location-search").value;
  loadLocations(searchTerm);
}

// On page load
window.onload = function () {
  initMap();
  setupInfiniteScroll();
};