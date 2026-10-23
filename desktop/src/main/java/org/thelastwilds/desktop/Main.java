package org.thelastwilds.desktop;

import org.thelastwilds.core.World;
import org.lwjgl.glfw.GLFW;
import org.lwjgl.opengl.GL;
import static org.lwjgl.opengl.GL11.*;

public final class Main {
    public static void main(String[] args) {
        if (!GLFW.glfwInit()) throw new IllegalStateException("GLFW initialization failed");
        long window = 0;
        try {
            GLFW.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MAJOR, 2);
            GLFW.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MINOR, 1);
            window = GLFW.glfwCreateWindow(960, 720, "The Last Wilds - Foundation", 0, 0);
            if (window == 0) throw new IllegalStateException("Window creation failed");
            GLFW.glfwMakeContextCurrent(window);
            GLFW.glfwSwapInterval(1);
            GL.createCapabilities();
            World world = new World(32, 24, 2026L);
            double previous = GLFW.glfwGetTime(), accumulator = 0;
            while (!GLFW.glfwWindowShouldClose(window)) {
                double now = GLFW.glfwGetTime();
                accumulator += Math.min(0.25, now - previous);
                previous = now;
                while (accumulator >= 1.0 / 60.0) { world.tick(); accumulator -= 1.0 / 60.0; }
                glViewport(0,0,960,720);
                glClearColor(0.07f,0.12f,0.10f,1f);
                glClear(GL_COLOR_BUFFER_BIT);
                glMatrixMode(GL_PROJECTION); glLoadIdentity();
                glOrtho(0,32,24,0,-1,1);
                glMatrixMode(GL_MODELVIEW); glLoadIdentity();
                glBegin(GL_QUADS);
                for (int y=0; y<world.height(); y++) for (int x=0; x<world.width(); x++) {
                    float green = world.biomass(x,y) / 130f;
                    glColor3f(0.09f,green,0.12f);
                    glVertex2f(x,y); glVertex2f(x+0.96f,y);
                    glVertex2f(x+0.96f,y+0.96f); glVertex2f(x,y+0.96f);
                }
                glEnd();
                GLFW.glfwSwapBuffers(window);
                GLFW.glfwPollEvents();
                if (GLFW.glfwGetKey(window, GLFW.GLFW_KEY_ESCAPE) == GLFW.GLFW_PRESS)
                    GLFW.glfwSetWindowShouldClose(window, true);
            }
        } finally {
            if (window != 0) GLFW.glfwDestroyWindow(window);
            GLFW.glfwTerminate();
        }
    }
}
