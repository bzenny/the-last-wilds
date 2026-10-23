package org.thelastwilds.core;

import java.util.Random;

public final class World {
    private final int width, height;
    private final int[][] biomass;
    private final Random random;
    private int tick;
    private int sanctuary = 100;

    public World(int width, int height, long seed) {
        if (width < 1 || height < 1) throw new IllegalArgumentException("World must have positive dimensions");
        this.width = width;
        this.height = height;
        this.random = new Random(seed);
        this.biomass = new int[height][width];
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                biomass[y][x] = 40 + random.nextInt(61);
    }

    public void tick() {
        tick++;
        if (tick % 60 == 0) {
            int x = random.nextInt(width), y = random.nextInt(height);
            biomass[y][x] = Math.min(100, biomass[y][x] + 1);
        }
    }

    public void log(int x, int y, int amount) {
        check(x, y);
        if (amount < 0) throw new IllegalArgumentException("amount must be nonnegative");
        biomass[y][x] = Math.max(0, biomass[y][x] - amount);
    }

    public int biomass(int x, int y) { check(x, y); return biomass[y][x]; }
    public int width() { return width; }
    public int height() { return height; }
    public int ticks() { return tick; }
    public int sanctuary() { return sanctuary; }
    public void damageSanctuary(int damage) {
        if (damage < 0) throw new IllegalArgumentException("damage must be nonnegative");
        sanctuary = Math.max(0, sanctuary - damage);
    }
    private void check(int x, int y) {
        if (x < 0 || x >= width || y < 0 || y >= height)
            throw new IndexOutOfBoundsException("tile " + x + "," + y);
    }
}
