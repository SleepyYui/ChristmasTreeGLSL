vec3 getMaterial(vec3 p, float id, vec3 normal) {
    vec3 m;
    switch (int(id)) {
        case 1:
            m = vec3(0.9, 0.0, 0.0); break;

        case 2:
            m = vec3(0.2 + 0.4 * mod(floor(p.x) + floor(p.z), 2.0)); break;

        case 3:
            m = vec3(0.7, 0.8, 0.9); break;

        case 4:
            vec2 i = step(fract(0.5 * p.xz), vec2(1.0 / 10.0));
            m = ((1.0 - i.x) * (1.0 - i.y)) * vec3(0.37, 0.12, 0.0); break;

        // würfel
        case 5:
            m = triPlanar(u_texture1, p * cubeScale, normal); break;

        // boden
        case 6:
            m = triPlanar(u_texture2, p * floorScale, normal); break;

        // wände
        case 7:
            m = triPlanar(u_texture3, p * wallScale, normal); break;

        // dach
        case 8:
            m = triPlanar(u_texture4, p * roofScale, normal); break;

        // stützen
        case 9:
            m = triPlanar(u_texture5, p * pedestalScale, normal); break;

        // tree
        case 10:
            m = vec3(0.0, 1.0, 0.0); // Bright green color for the tree
            break;

        // Ornaments
        case 11:
            m = vec3(1.0, 0.0, 0.0); // Red color for ornaments
            break;

        // Star
        case 12:
            m = vec3(1.0, 1.0, 0.0); // Yellow color for the star
            break;

        default:
            m = vec3(0.4); break;
    }
    return m;
}
