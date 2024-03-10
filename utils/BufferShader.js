import * as THREE from 'three';
import { vertex } from './VERTEX';

export class BufferShader {

  constructor(fragmentShader, uniforms = {}) {

    this.uniforms = uniforms;
    this.material = new THREE.ShaderMaterial({
      fragmentShader: fragmentShader,
      vertexShader: vertex,
      uniforms: uniforms
    });
    this.scene = new THREE.Scene();
    this.scene.add(
      new THREE.Mesh(new THREE.PlaneGeometry(2, 2), this.material)
    );
  }

}