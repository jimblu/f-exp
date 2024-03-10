import * as THREE from 'three';
import { TextGeometry } from 'three/addons/geometries/TextGeometry.js';
import { FontLoader } from 'three/addons/loaders/FontLoader.js';

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer({ antialias: true}); 
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setClearColor(0xEEEEEE);
document.body.appendChild(renderer.domElement);

const textureLoader = new THREE.TextureLoader();
const loaderFont = new FontLoader();
const loaderFile = new THREE.FileLoader();
loaderFile.load('./vertex.glsl', (vertex) => {
loaderFile.load(
  // './fragment6.glsl'
  // './fragment5.glsl'
  // './fragment4.glsl'
  // './fragment3.glsl'
  // './fragment2.glsl'
  // './fragment.glsl'
  , (fragment) => {
textureLoader.load(
  // './nature.jpg'
  './cuivre.jpg'
  , (texture) => {
loaderFont.load( 
  // './Vazirmatn ExtraBold_Regular.json'
  './Vazirmatn_Regular.json'
  , function ( font ) {
    let mouseX;
    let mouseY;
    document.addEventListener('mousemove', (event) => {
      // Convertir les coordonnées de la souris en valeurs normalisées entre -1 et 1
      mouseX = (event.clientX / window.innerWidth) * 2 - 1;
      mouseY = -(event.clientY / window.innerHeight) * 2 + 1;
  
      // Mettre à jour l'uniforme iMouse avec les coordonnées de la souris
      // uniforms.iMouse.value.set(mouseX, mouseY);
  });

  const uniforms = {
    iTime: { value: 0.0 },
    iTexture: { value: new THREE.TextureLoader().load('./txt.svg') },
    iResolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
    iChannel0: { value: texture },
    iMouse: { value: new THREE.Vector2() }
  };
  const textGeometry = new TextGeometry( 
    '          We are an experimental\n arts x music festival in the\n midst of the Swedish forest.'
    // 'HYBRIDA FEST'
    // 'forest'
    , {
    font: font,
    size: 70,
    height: 0,
  });
  const textMaterial = new THREE.ShaderMaterial({
    vertexShader: vertex,
    fragmentShader: fragment,
    uniforms: uniforms
  })
  const textMesh = new THREE.Mesh(textGeometry, textMaterial);
  scene.add(textMesh);
  // textMesh.position.set(-10, 0, 1); 

  let startTime = Date.now(); //
  function animate() {
    // console.warn(uniforms.iMouse)
    requestAnimationFrame(animate);
    const elapsedTime = Date.now() - startTime;
    uniforms.iTime.value = elapsedTime / 1000;
    uniforms.iResolution.value.set(window.innerWidth, window.innerHeight);
    uniforms.iMouse.value.set(mouseX, mouseY);
    renderer.render(scene, camera);
  }
  animate();

});
})
})
})
camera.position.x = 700;
camera.position.z = 500;
camera.position.y = -150;

window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
});
