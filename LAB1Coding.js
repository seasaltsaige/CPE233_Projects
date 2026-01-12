// Initialize array and fill empty array with all zeros initially.
const arr = new Array(256).fill(0);

// Loop through array and fill random spots with numbers, replacing the zeros
for (let i = 0; i < arr.length; i++) {
  if (Math.random() <= 0.4) arr[i] = Math.floor(Math.random() * 100) + 1;
}

// Loop through the array, look for locations with zeros still, 
// replace them with 0xFFFF
for (let j = 0; j < arr.length; j++) {
  if (arr[j] === 0) arr[j] = 0xFFFF;
}

// Print values held in array
console.log(arr);