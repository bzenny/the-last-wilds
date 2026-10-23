package org.thelastwilds.desktop;

import org.thelastwilds.core.Encounter;
import org.thelastwilds.core.Encounter.Unit;
import org.lwjgl.glfw.GLFW;
import org.lwjgl.opengl.GL;
import static org.lwjgl.opengl.GL11.*;

/** Low-fidelity playable vertical slice. No art dependencies. */
public final class Main {
    private static final int WIDTH=960, HEIGHT=720;
    private static boolean wasSpace, wasClick, wasRight, wasQ, wasR;
    public static void main(String[] args) {
        if (!GLFW.glfwInit()) throw new IllegalStateException("GLFW initialization failed");
        long window=0;
        try {
            GLFW.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MAJOR,2);
            GLFW.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MINOR,1);
            window=GLFW.glfwCreateWindow(WIDTH,HEIGHT,"The Last Wilds - First Clearing",0,0);
            if(window==0)throw new IllegalStateException("Window creation failed");
            GLFW.glfwMakeContextCurrent(window);
            GLFW.glfwSwapInterval(1);
            GL.createCapabilities();
            Encounter game=new Encounter(2026L);
            double previous=GLFW.glfwGetTime(), accumulator=0;
            while(!GLFW.glfwWindowShouldClose(window)){
                double now=GLFW.glfwGetTime();
                accumulator+=Math.min(.25,now-previous);previous=now;
                boolean space=down(window,GLFW.GLFW_KEY_SPACE);
                if(space&&!wasSpace)game.togglePause();wasSpace=space;
                boolean restart=down(window,GLFW.GLFW_KEY_R);
                if(restart&&!wasR)game=new Encounter(2026L);wasR=restart;
                for(int i=0;i<3;i++)if(down(window,GLFW.GLFW_KEY_1+i))game.select(i);
                double[] mx=new double[1],my=new double[1];
                GLFW.glfwGetCursorPos(window,mx,my);
                int x=(int)(mx[0]/30),y=(int)(my[0]/30);
                boolean valid=x>=0&&x<32&&y>=0&&y<24;
                boolean left=GLFW.glfwGetMouseButton(window,GLFW.GLFW_MOUSE_BUTTON_LEFT)==GLFW.GLFW_PRESS;
                boolean right=GLFW.glfwGetMouseButton(window,GLFW.GLFW_MOUSE_BUTTON_RIGHT)==GLFW.GLFW_PRESS;
                boolean q=down(window,GLFW.GLFW_KEY_Q);
                if(left&&!wasClick&&valid){
                    for(int i=0;i<3;i++){Unit u=game.units().get(i);if(u.x==x&&u.y==y)game.select(i);}
                }
                if(right&&!wasRight&&valid)game.command(x,y);
                if(q&&!wasQ&&valid)game.ability(x,y);
                wasClick=left;wasRight=right;wasQ=q;
                if(down(window,GLFW.GLFW_KEY_ESCAPE))GLFW.glfwSetWindowShouldClose(window,true);
                while(accumulator>=1.0/60){game.step();accumulator-=1.0/60;}
                glViewport(0,0,WIDTH,HEIGHT);
                glClearColor(.06f,.09f,.08f,1);glClear(GL_COLOR_BUFFER_BIT);
                glMatrixMode(GL_PROJECTION);glLoadIdentity();glOrtho(0,32,24,0,-1,1);
                glMatrixMode(GL_MODELVIEW);glLoadIdentity();
                for(int yy=0;yy<24;yy++)for(int xx=0;xx<32;xx++){
                    float b=game.world().biomass(xx,yy)/130f;
                    if(game.road(xx,yy))quad(xx,yy,.42f,.32f,.19f,.98f);
                    else quad(xx,yy,.10f,b,.14f,.98f);
                }
                quad(15,11,.92f,.82f,.22f,2f);
                for(int i=0;i<game.units().size();i++){
                    Unit u=game.units().get(i);if(u.hp<=0)continue;
                    float red=u.human?.85f:.15f, green=u.human?.20f:.72f,blue=u.human?.12f:.90f;
                    quad(u.x+.15f,u.y+.15f,red,green,blue,.68f);
                    if(i==game.selected())outline(u.x,u.y);
                }
                GLFW.glfwSetWindowTitle(window,"The Last Wilds | "+(game.paused()?"PAUSED":"RUNNING")+" | Wild Energy "+game.energy()+" | Sanctuary "+game.world().sanctuary()+" | Humans stopped "+game.halted()+"/3 | "+(game.finished()?(game.won()?"VICTORY":"DEFEAT"):"1-3 select, Right click move, Q ability at cursor, Space pause, R restart"));
                GLFW.glfwSwapBuffers(window);GLFW.glfwPollEvents();
            }
        }finally{if(window!=0)GLFW.glfwDestroyWindow(window);GLFW.glfwTerminate();}
    }
    private static boolean down(long w,int k){return GLFW.glfwGetKey(w,k)==GLFW.GLFW_PRESS;}
    private static void quad(float x,float y,float r,float g,float b,float size){
        glColor3f(r,g,b);glBegin(GL_QUADS);
        glVertex2f(x,y);glVertex2f(x+size,y);glVertex2f(x+size,y+size);glVertex2f(x,y+size);glEnd();
    }
    private static void outline(float x,float y){
        glColor3f(1,1,1);glBegin(GL_LINE_LOOP);
        glVertex2f(x,y);glVertex2f(x+1,y);glVertex2f(x+1,y+1);glVertex2f(x,y+1);glEnd();
    }
}
