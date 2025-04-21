// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCACz8mdgjzvVyRgq2jTp-RV3yhFbVkqRk",
  authDomain: "butter-begin.firebaseapp.com",
  projectId: "butter-begin",
  storageBucket: "butter-begin.firebasestorage.app",
  messagingSenderId: "412954167340",
  appId: "1:412954167340:web:0f1aa69648129a8c6a6989",
  measurementId: "G-KBVYVPFHHE"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Vérifiez si l'objet 'window' est défini avant d'initialiser Analytics
if (typeof window !== 'undefined') {
    const analytics = getAnalytics(app);
    // Vous pouvez maintenant utiliser l'objet analytics
  }

  import { getStorage, ref, getDownloadURL } from "firebase/storage";

// Initialisez Firebase Storage
const storage = getStorage();

// Créez une référence au fichier dans Firebase Storage
const fileRef = ref(storage, 'ADL2.png'); // Utilisez le chemin relatif dans le bucket

// Obtenez l'URL de téléchargement
getDownloadURL(fileRef)
  .then((url) => {
    // Utilisez l'URL comme nécessaire
    console.log('URL de téléchargement :', url);
  })
  .catch((error) => {
    // Gérer les erreurs
    console.error('Erreur lors de la récupération de l\'URL :', error);
  });
