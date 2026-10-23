package org.thelastwilds.core;

import java.util.*;

/** Deterministic, UI-independent first-play encounter. Coordinates are tile based. */
public final class Encounter {
    public enum Kind { ROOTLING, BRUTE, SPITTER, LOGGER, GUARD, SETTLER }
    public static final class Unit {
        public final Kind kind;
        public int x, y, hp;
        public boolean human;
        Unit(Kind kind, int x, int y, int hp, boolean human) {
            this.kind=kind; this.x=x; this.y=y; this.hp=hp; this.human=human;
        }
    }
    private final World world;
    private final List<Unit> units = new ArrayList<>();
    private final int[][] road = new int[24][32];
    private final Random rng;
    private int ticks, energy=30, selected=0, halted=0;
    private boolean paused=true;
    public Encounter(long seed) {
        rng = new Random(seed);
        world = new World(32,24,seed);
        units.add(new Unit(Kind.ROOTLING,10,11,30,false));
        units.add(new Unit(Kind.BRUTE,11,13,65,false));
        units.add(new Unit(Kind.SPITTER,9,15,24,false));
        units.add(new Unit(Kind.LOGGER,28,11,18,true));
        units.add(new Unit(Kind.GUARD,30,13,36,true));
        units.add(new Unit(Kind.SETTLER,29,17,22,true));
        for (int x=23;x<32;x++) road[12][x]=1;
    }
    public World world(){return world;}
    public List<Unit> units(){return Collections.unmodifiableList(units);}
    public int energy(){return energy;}
    public int ticks(){return ticks;}
    public int selected(){return selected;}
    public int halted(){return halted;}
    public boolean paused(){return paused;}
    public void togglePause(){paused=!paused;}
    public boolean finished(){return world.sanctuary()==0 || halted>=3 || ticks>=3600;}
    public boolean won(){return world.sanctuary()>0 && halted>=3;}
    public boolean road(int x,int y){return road[y][x]!=0;}
    public void select(int index){if(index>=0 && index<3)selected=index;}
    public void command(int x,int y) {
        if(finished() || x<0 || x>=32 || y<0 || y>=24)return;
        Unit u=units.get(selected);
        if(u.hp>0){u.x=x;u.y=y;}
    }
    public boolean ability(int x,int y){
        if(finished() || x<0 || x>=32 || y<0 || y>=24)return false;
        Unit u=units.get(selected);
        if(u.hp<=0 || energy<8 || distance(u.x,u.y,x,y)>5)return false;
        if(u.kind==Kind.ROOTLING){world.log(x,y,0);energy-=8; return regrow(x,y);}
        if(u.kind==Kind.BRUTE && road[y][x]!=0){road[y][x]=0;energy-=8;return true;}
        if(u.kind==Kind.SPITTER){
            for(Unit enemy:units)if(enemy.human && enemy.hp>0 && distance(enemy.x,enemy.y,x,y)<=2){
                enemy.hp=Math.max(0,enemy.hp-12);energy-=8;return true;
            }
        }
        return false;
    }
    private boolean regrow(int x,int y){ // regeneration via an explicit restorative action
        int before=world.biomass(x,y);
        // World tracks loss through logging; regrowth is modeled as negative loss via dedicated API.
        world.restore(x,y,25);
        return world.biomass(x,y)>before;
    }
    public void step(){
        if(paused || finished())return;
        ticks++;world.tick();
        if(ticks%60==0) {
            energy=Math.min(100,energy+2);
            for(Unit human:units) {
                if(!human.human || human.hp<=0)continue;
                Unit defender=nearestDefender(human);
                if(defender!=null && distance(human.x,human.y,defender.x,defender.y)<=2) {
                    if(human.kind==Kind.GUARD)defender.hp=Math.max(0,defender.hp-5);
                    else moveAway(human,defender);
                } else {
                    int tx=16, ty=12;
                    if(human.kind==Kind.LOGGER){tx=19;ty=11;}
                    if(human.kind==Kind.SETTLER){tx=20;ty=17;}
                    moveToward(human,tx,ty);
                    if(human.kind==Kind.LOGGER && human.x<=20)world.log(human.x,human.y,12);
                    if(human.kind==Kind.SETTLER && human.x<=21)road[human.y][human.x]=1;
                    if(human.x<=14)world.damageSanctuary(4);
                }
            }
            for(Unit defender:units) {
                if(defender.human || defender.hp<=0)continue;
                Unit target=nearestHuman(defender);
                int range=defender.kind==Kind.SPITTER?5:2;
                if(target!=null && distance(defender.x,defender.y,target.x,target.y)<=range)
                    target.hp=Math.max(0,target.hp-(defender.kind==Kind.BRUTE?12:7));
            }
            halted=0;
            for(Unit u:units)if(u.human && u.hp==0)halted++;
        }
    }
    private Unit nearestHuman(Unit from){return nearest(from,true);}
    private Unit nearestDefender(Unit from){return nearest(from,false);}
    private Unit nearest(Unit from,boolean human){
        Unit best=null;int d=Integer.MAX_VALUE;
        for(Unit u:units)if(u.human==human && u.hp>0){
            int dist=distance(from.x,from.y,u.x,u.y);
            if(dist<d){d=dist;best=u;}
        }
        return best;
    }
    private static int distance(int x,int y,int a,int b){return Math.abs(x-a)+Math.abs(y-b);}
    private static void moveToward(Unit u,int x,int y){
        if(u.x!=x)u.x+=Integer.compare(x,u.x);
        else if(u.y!=y)u.y+=Integer.compare(y,u.y);
    }
    private static void moveAway(Unit u,Unit from){
        u.x=Math.max(0,Math.min(31,u.x+Integer.compare(u.x,from.x)));
    }
}
