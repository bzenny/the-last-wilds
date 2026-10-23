package org.thelastwilds.core;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class WorldTest {
    @Test void seededWorldIsDeterministic() {
        World a = new World(8, 8, 42), b = new World(8, 8, 42);
        for (int i = 0; i < 600; i++) { a.tick(); b.tick(); }
        for (int y = 0; y < 8; y++) for (int x = 0; x < 8; x++)
            assertEquals(a.biomass(x,y), b.biomass(x,y));
    }
    @Test void loggingClampsToZero() {
        World w = new World(2,2,1);
        w.log(0,0,999);
        assertEquals(0,w.biomass(0,0));
    }
    @Test void sanctuaryCannotGoNegative() {
        World w = new World(2,2,1);
        w.damageSanctuary(1000);
        assertEquals(0,w.sanctuary());
    }
    @Test void rejectsInvalidDimensions() {
        assertThrows(IllegalArgumentException.class, () -> new World(0,4,1));
    }
}
