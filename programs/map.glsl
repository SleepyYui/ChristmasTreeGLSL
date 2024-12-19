#include "common.glsl"

float trunkHeight = TRUNK_HEIGHT;
float trunkRadius = 1.0;    // Previously 0.3

float coneHeight = CONE_HEIGHT;
float coneRadius = 7.0;     // Previously 2.0

// Recalculate cone angle
float coneAngle = atan(coneRadius / coneHeight);

// Simple hash function for noise
float hash(float n) {
    return fract(sin(n) * 1e4);
}

// 3D Perlin-like noise function
float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f * f * (3.0 - 2.0 * f);

    float n = p.x + p.y * 57.0 + p.z * 113.0;

    return mix(mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
                   mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
               mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                   mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
}

float fCylinderY(vec3 p, float r, float h) {
    vec2 d = abs(vec2(length(p.xz), p.y - h * 0.5)) - vec2(r, h * 0.5);
    return min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0)));
}

vec2 map(vec3 p) {
    vec3 tmp, op = p;

    // Ground plane
    float planeDist = fPlane(p, vec3(0, 1, 0), 0.0);
    float planeID = 6.0;

    // Tree transformations
    vec3 ps = p;
    translateTree(ps);
    rotateTree(ps);

    // Trunk
    float trunkHeight = 10.0;
    float trunkRadius = 1.0;
    float trunkDist = fCylinderY(ps, trunkRadius, trunkHeight);

    // Initialize tree distance and ID
    float treeDist = trunkDist;
    float treeID = 10.0; // Trunk ID

    // Branch layers (cones)
    int numBranches = 7;
    for (int i = 0; i < numBranches; i++) {
        float level = float(i);
        float currentConeHeight = coneHeight / float(numBranches);
        float currentConeRadius = mix(coneRadius, 0.0, level / float(numBranches - 1));

        vec3 branchPos = ps;
        branchPos.y -= trunkHeight + level * currentConeHeight;
        float branchDist = fCone(branchPos, currentConeRadius, currentConeHeight*2);

        // Apply adjusted noise (displacement)
        float noiseScale = 0.5;
        float displacement = (noise(branchPos * noiseScale) - 0.5) * 0.5;
        branchDist += displacement;

        // Combine with tree distance
        if (branchDist < treeDist) {
            treeDist = branchDist;
            treeID = 10.0; // Keep same ID for branches
        }
    }

    // Ornaments
    int numOrnaments = 50;
    float ornamentRadius = 0.3;

    for (int i = 0; i < numOrnaments; i++) {
        float rand1 = hash(float(i) * 13.13);
        float rand2 = hash(float(i) * 7.77);

        float theta = rand1 * 2.0 * PI;
        float height = rand2 * coneHeight;

        float radiusAtHeight = mix(coneRadius, 0.0, height / coneHeight);
        vec3 ornamentPos = ps;
        ornamentPos.y -= trunkHeight + height;
        ornamentPos.x += (radiusAtHeight + 0.5) * cos(theta);
        ornamentPos.z += (radiusAtHeight + 0.5) * sin(theta);

        float ornamentDist = length(ornamentPos) - ornamentRadius;

        if (ornamentDist < treeDist) {
            treeDist = ornamentDist;
            treeID = 11.0; // Ornament ID
        }
    }

    // Star at the top
    vec3 starPos = ps;
    starPos.y -= trunkHeight + coneHeight + 2.0;
    float starDist = length(starPos) - 1.0;

    if (starDist < treeDist) {
        treeDist = starDist;
        treeID = 12.0; // Star ID
    }

    // Combine tree with ground plane
    vec2 res = vec2(1e5, 0.0);
    res = fOpUnionID(res, vec2(treeDist, treeID));
    res = fOpUnionID(res, vec2(planeDist, planeID));

    return res;
}