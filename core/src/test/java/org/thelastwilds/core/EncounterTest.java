package org.thelastwilds.core;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class EncounterTest {
    @Test void pauseFreezesSimulation() {
        Encounter e=new Encounter(7);
        for(int i=0;i<120;i++)e.step();
        assertEquals(0,e.ticks());
        e.togglePause();e.step();assertEquals(1,e.ticks());
    }
    @Test void sameSeedSameOutcome() {
        Encounter a=new Encounter(8),b=new Encounter(8);
        a.togglePause();b.togglePause();
        for(int i=0;i<1000;i++){a.step();b.step();}
        assertEquals(a.world().sanctuary(),b.world().sanctuary());
        assertEquals(a.energy(),b.energy());
        for(int y=0;y<24;y++)for(int x=0;x<32;x++)
            assertEquals(a.world().biomass(x,y),b.world().biomass(x,y));
    }
    @Test void guardianCanBeCommandedWhilePaused() {
        Encounter e=new Encounter(1);e.select(1);e.command(8,9);
        assertEquals(8,e.units().get(1).x);
        assertEquals(0,e.ticks());
    }
}
