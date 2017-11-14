import processing.video.*;
import ddf.minim.*;
import java.util.StringTokenizer;
Capture video;
PImage hand;
PImage[][]page=new PImage[2][10];
PImage[][]leftboard=new PImage[10][3], rightboard=new PImage[9][3], back=new PImage[2][3];
PImage[][]num=new PImage[2][10], menubutton=new PImage[3][3], buttondc=new PImage[1][5];
int ex, ey, sx, sy, range=0, finger=15, bu=1, /*計時器*/presec=0, sec=0, seco=0, minu=0;
int secdigitinones=0, secdigitintens=0, mindigitinones=0, mindigitintens=0;
int move=1, movex=0, movey=80/*播放時間*/, shapey=0, colory=0, time, sizey=1, speedy=1, score=0;
int sc=3, rs=-1, boss=0, bossx=0, bossy=0, bossz=0;
int a=0, b=0, c=0, d=0, e=0, f=0, g=0, h=0, dc = 1;//感應顏色 紅=0,綠=1,藍=2
int m = 10, n = 10, o = 6, p = 6, q = 2, r = 2;//接觸多久確認
int statu = 15, st = 0;//statu第幾頁
float brightestX, brightestY, rx, ry, rn, prex, prey; 
float brightestValue = 90, pixelBrightness, touchrange, si;
boolean tc = false, detect = false, alphax = true;
String music = "mus1.mp3";//音樂
int colorred = 255, colorgreen = 255, colorblue = 0;//顏色
int[][] step = new int[100][3];
String buf[];//軌跡文件
StringTokenizer strin;
Minim minim;
AudioPlayer player;

void setup(){
  String[] cameras = Capture.list();
  println(cameras);
  fullScreen();
  //size(1280, 720);
  hand =loadImage("hand.png");
  for(int i=0;i<1;i++)for(int j=0;j<10;j++)page[i][j] =loadImage("p"+i+j+".png");
  for(int i=1;i<2;i++)for(int j=0;j<6;j++)page[i][j] =loadImage("p"+i+j+".png");
  for(int i=0;i<2;i++)for(int j=0;j<10;j++)num[i][j] =loadImage("num"+i+j+".png");
  for(int i=0;i<3;i++)for(int j=0;j<3;j++)menubutton[i][j] =loadImage("m"+i+j+".png");
  for(int i=0;i<10;i++)for(int j=0;j<3;j++)leftboard[i][j] =loadImage("lb"+i+j+".png");
  for(int i=0;i<9;i++)for(int j=0;j<3;j++)rightboard[i][j] =loadImage("rb"+i+j+".png");
  for(int i=0;i<2;i++)for(int j=0;j<3;j++)back[i][j] =loadImage("b"+i+j+".png");
  video = new Capture(this, 1280, 720);
  video.start();
  buf = loadStrings("line1.txt");
  touchrange = width*0.05;
  si = width*0.045;
  ex = width/2;
  ey = height/10;
  minim = new Minim(this);
}

void draw(){
  switch(statu){
  case 0://首頁
    st = 1;
    detect(2);//找出最X點的位置
    touchmenu();
    break;
    
  case 13://選感應顏色
    st = 14;
    detect(2);//找出最X點的位置
    touchdc();
    break;

  case 1://選形狀
    st = 2;
    detect(2);//找出最X點的位置
    touchII();
    break;

  case 2://選顏色
    st = 3;
    detect(2);//找出最X點的位置
    touchII();
    break;

  case 3://選尺寸
    st = 4;
    detect(2);//找出最X點的位置
    touchIII();
    break;

  case 4://選軌跡
    st = 5;
    detect(2);//找出最X點的位置
    touchIII();
    break;
    
  case 5://選速度
    st = 6;
    detect(2);//找出最X點的位置
    touchIII();
    break;
    
  case 6://選音樂
    st = 7;
    detect(2);//找出最X點的位置
    touchIII();
    break;   

  case 7://選次數
    st = 9;
    detect(2);//找出最X點的位置
    touchIII();
    break;
  
  case 9://確認開始
    st =  10;
    detect(2);
    touchstart();
    break;
  case 10://視訊畫面
    st = 11;
    detect(1);//找出最X點的位置
    touchX();
    break;
      
  case 11://統計頁面
    gameover();
    detect(0);//找出最X點的位置
    touchgameover();
    break;
      
  case 12://暫停頁面
    if(alphax==true){
      alphax = false;
      image(page[1][2], 0, 0, width, height);
    }
    touchpause();
    break;
    
  case 14://測試頁面
    st = 0;
    detect = true;
    detect(0);
    touchtest();
    break;
    
  case 15://操作模式
    st = 13;
    detect(2);
    touchmode();
    break;
  
  case 99:
    st = 11;
    boss = 1;
    detect(1);
    touchX();
    break;
  }
}
//-----------------------------------以下為各種fuction
void detect(int show){
  if (video.available()){
    video.read();
    scale(-1, 1);
    rx=0;
    ry=0;
    rn=0;
    brightestX = 0; 
    brightestY = 0; 
    video.loadPixels();
    int index = 0;
    for (float y = 0; y < video.height; y++){
      for (float x = 0; x < video.width; x++){
        int pixelValue = video.pixels[index];
        if(dc==0)//抓紅
        pixelBrightness = red(pixelValue)-(green(pixelValue)+blue(pixelValue))/2;
        if(dc==1)//抓綠
        pixelBrightness = green(pixelValue)-(red(pixelValue)+blue(pixelValue))/2;
        if(dc==2)//抓藍
        pixelBrightness = blue(pixelValue)-(green(pixelValue)+red(pixelValue))/2;
        if (pixelBrightness > brightestValue){
          brightestY = y;
          brightestX = (x-1280);//反轉畫面後修改X軸
          brightestX = brightestX*(width/1280)*(1.15);//調整座標位置
          brightestY = brightestY*(height/720)*(1.25);
          rx+=brightestX;
          ry+=brightestY;
          rn++;
        }
        index++;
        
      }
    }
    if(show==0)image(video, 0, 0, -width, height);
    if(show==1)image(page[1][0], 0, 0, -width, height);
    if(statu==0){
      image(page[0][0], 0, 0, -width, height);
      if(a==1)image(menubutton[1][0], -width*0.015, height*0.687, -width*0.375, height*0.25);
      if(b==1)image(menubutton[1][1], -width*0.315, height*0.687, -width*0.375, height*0.25);
      if(c==1)image(menubutton[1][2], -width*0.615, height*0.687, -width*0.375, height*0.25);
    }
    if(statu==13){
      image(page[1][4], 0, 0, -width, height);
      if(a==1)image(rightboard[8][0], -width*0.661, height*0.424, -width*0.25, height*0.125);
      if(b==1)image(rightboard[8][1], -width*0.661, height*0.605, -width*0.25, height*0.125);
      if(c==1)image(rightboard[8][2], -width*0.661, height*0.782, -width*0.25, height*0.125);
      if(e==1)image(back[1][1], -width*0.773, height*0.18, -width*0.25, height*0.125);
    }
    if(statu==1){
        image(page[0][1], 0, 0, -width, height);
        if(a==1)image(rightboard[1][0], -width*0.661, height*0.47, -width*0.25, height*0.125);
        if(b==1)image(rightboard[1][1], -width*0.661, height*0.695, -width*0.25, height*0.125);
        if(d==1)image(back[1][0], -width*0.605, height*0.18, -width*0.25, height*0.125);
        if(e==1)image(back[1][1], -width*0.773, height*0.18, -width*0.25, height*0.125);
        if(f==1)image(leftboard[0][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(g==1)image(leftboard[0][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
      }
    if(statu==2){
      image(page[0][2], 0, 0, -width, height);
      if(a==1)image(rightboard[2][0], -width*0.661, height*0.47, -width*0.25, height*0.125);
      if(b==1)image(rightboard[2][1], -width*0.661, height*0.7, -width*0.25, height*0.125);
      if(d==1)image(back[1][0], -width*0.605, height*0.18, -width*0.25, height*0.125);
      if(e==1)image(back[1][1], -width*0.773, height*0.18, -width*0.25, height*0.125);
      if(f==1){
        if(shapey==0)image(leftboard[0][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==1)image(leftboard[1][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
      }
      if(g==1){
        if(shapey==0)image(leftboard[1][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==1)image(leftboard[1][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
      }
    }
    if(statu==3){
      image(page[0][3], 0, 0, -width, height);
      if(a==1)image(rightboard[3][0], -width*0.661, height*0.424, -width*0.25, height*0.125);
      if(b==1)image(rightboard[3][1], -width*0.661, height*0.605, -width*0.25, height*0.125);
      if(c==1)image(rightboard[3][2], -width*0.661, height*0.782, -width*0.25, height*0.125);
      if(d==1)image(back[1][0], -width*0.605, height*0.18, -width*0.25, height*0.125);
      if(e==1)image(back[1][1], -width*0.773, height*0.18, -width*0.25, height*0.125);
      if(f==1){
        if(shapey==0&&colory==0)image(leftboard[2][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==1&&colory==0)image(leftboard[7][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==0&&colory==1)image(leftboard[8][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==1&&colory==1)image(leftboard[9][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
      }
      if(g==1){
        if(shapey==0&&colory==0)image(leftboard[2][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==1&&colory==0)image(leftboard[7][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==0&&colory==1)image(leftboard[8][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==1&&colory==1)image(leftboard[9][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
      }
      if(h==1){
        if(shapey==0&&colory==0)image(leftboard[2][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==1&&colory==0)image(leftboard[7][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==0&&colory==1)image(leftboard[8][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
        if(shapey==1&&colory==1)image(leftboard[9][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
      }
    }
    if(statu==4){
      image(page[0][4], 0, 0, -width, height);
      if(a==1)image(rightboard[4][0], -width*0.661, height*0.424, -width*0.25, height*0.125);
      if(b==1)image(rightboard[4][1], -width*0.661, height*0.605, -width*0.25, height*0.125);
      if(c==1)image(rightboard[4][2], -width*0.661, height*0.782, -width*0.25, height*0.125);
      if(d==1)image(back[1][0], -width*0.605, height*0.18, -width*0.25, height*0.125);
      if(e==1)image(back[1][1], -width*0.773, height*0.18, -width*0.25, height*0.125);
      if(f==1)image(leftboard[3][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
      if(g==1)image(leftboard[3][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
      if(h==1)image(leftboard[3][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
    }
    if(statu==5){
      image(page[0][5], 0, 0, -width, height);
      if(a==1)image(rightboard[5][0], -width*0.661, height*0.424, -width*0.25, height*0.125);
      if(b==1)image(rightboard[5][1], -width*0.661, height*0.605, -width*0.25, height*0.125);
      if(c==1)image(rightboard[5][2], -width*0.661, height*0.782, -width*0.25, height*0.125);
      if(d==1)image(back[1][0], -width*0.605, height*0.18, -width*0.25, height*0.125);
      if(e==1)image(back[1][1], -width*0.773, height*0.18, -width*0.25, height*0.125);
      if(f==1)image(leftboard[4][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
      if(g==1)image(leftboard[4][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
      if(h==1)image(leftboard[4][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
    }
    if(statu==6){
      image(page[0][6], 0, 0, -width, height);
      if(a==1)image(rightboard[6][0], -width*0.661, height*0.424, -width*0.25, height*0.125);
      if(b==1)image(rightboard[6][1], -width*0.661, height*0.605, -width*0.25, height*0.125);
      if(c==1)image(rightboard[6][2], -width*0.661, height*0.782, -width*0.25, height*0.125);
      if(d==1)image(back[1][0], -width*0.605, height*0.18, -width*0.25, height*0.125);
      if(e==1)image(back[1][1], -width*0.773, height*0.18, -width*0.25, height*0.125);
      if(f==1)image(leftboard[5][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
      if(g==1)image(leftboard[5][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
      if(h==1)image(leftboard[5][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
    }
    if(statu==7){
      image(page[0][7], 0, 0, -width, height);
      if(a==1)image(rightboard[7][0], -width*0.661, height*0.424, -width*0.25, height*0.125);
      if(b==1)image(rightboard[7][1], -width*0.661, height*0.605, -width*0.25, height*0.125);
      if(c==1)image(rightboard[7][2], -width*0.661, height*0.782, -width*0.25, height*0.125);
      if(d==1)image(back[1][0], -width*0.605, height*0.18, -width*0.25, height*0.125);
      if(e==1)image(back[1][1], -width*0.773, height*0.18, -width*0.25, height*0.125);
      if(f==1)image(leftboard[6][0], -width*0.061, height*0.47, -width*0.5, height*0.5);
      if(g==1)image(leftboard[6][1], -width*0.061, height*0.47, -width*0.5, height*0.5);
      if(h==1)image(leftboard[6][2], -width*0.061, height*0.47, -width*0.5, height*0.5);
    }
    if(statu==9)image(page[0][9], 0, 0, -width, height);
    if(statu==10)line1();//運動方式
    if(statu==11){//統計頁面
      image(page[1][1], 0, 0, -width, height);
      image(num[0][secdigitinones], -width*0.58, height*0.59, -width*0.1875, height*0.25);
      image(num[0][secdigitintens], -width*0.48, height*0.59, -width*0.1875, height*0.25);
      image(num[1][mindigitinones], -width*0.33, height*0.59, -width*0.1875, height*0.25);
      image(num[1][mindigitintens], -width*0.23, height*0.59, -width*0.1875, height*0.25);
      if(a==1)image(back[1][2], -width*0.545, height*0.205, -width*0.25, height*0.125);
      if(e==1)image(back[1][1], -width*0.748, height*0.205, -width*0.25, height*0.125);
    }
    if(statu==14){
      image(page[1][3], 0, 0, -width, height);
      if(a==1)image(menubutton[2][0], -width*0.311, height*0.654, -width*0.375, height*0.25);
      if(d==1)image(back[1][0], -width*0.738, height*0.07, -width*0.25, height*0.125);
    }
    if(statu==15){
      image(page[1][5], 0, 0, -width, height);
    }
    if(statu==99)line0();//隱藏關卡
    if (detect==true&&rn>10){
      brightestX=rx/rn;
      brightestY=ry/rn;
      prex=brightestX;
      prey=brightestY;
      image(hand, brightestX-(hand.width/2), brightestY-(hand.height/2), hand.width*width/1280, hand.height*height/720);
    }
    if(detect==false){
      if(mousePressed==true){
        brightestX=-mouseX;
        brightestY=mouseY;
        prex=brightestX;
        prey=brightestY;
        image(hand, brightestX-(hand.width/2), brightestY-(hand.height/2), hand.width*width/1280, hand.height*height/720);
      }
    }
    else{
      if (finger>0){
        finger--;
        image(hand, prex-(hand.width/2), prey-(hand.height/2), hand.width*width/1280, hand.height*height/720);
      }
    }
  }
}
//-------------------------各種形狀
void shapeX(){
  if(shapey==0){
    ellipseMode(RADIUS);
    ellipse(-ex, ey, si, si);
  }
  if(shapey==1){
    rectMode(RADIUS);
    rect(-ex, ey, si, si);
  }
}
//----------------------顏色
void colorx(){
  if(colory==0){
    colorred = 255;
    colorgreen = 255;
    colorblue = 0;
  }
  if(colory==1){
    colorred = 255;
    colorgreen = 0;
    colorblue = 0;
  }
}
//---------------------------------各種尺寸
void sizeX(){
  if(sizey==0)si = width*0.065;
  if(sizey==1)si = width*0.045;
  if(sizey==2)si = width*0.025;
}
//-------------------------隨機軌跡
void line0(){
  if(move==0){//不移動
    sizeX();
    colorx();
    fill(colorred, colorgreen, colorblue);
    shapeX();
    movex++;
    if(movex>movey){
      if(score==sc){//訓練結束
        score = 0;
        statu = st;
        sec = millis() - presec + sec;
        if(player!=null) player.pause();
        if(sec<60000)seco = sec/1000;//計算時間
        else if(sec<3600000){
          seco = (sec/1000)%60;
          minu = (sec/1000)/60;
        }
      }
      else{
        movex = 0;
        move = 1;
        m = n;
        player.pause();
      }
    }
  }
  if(move==1){//移動
    if(range>0){
      range--;
    }
    else{
      sx=int(random(-22, 22));
      sy=int(random(-22, 22));
      range=int(random(22));
    }
    if(ex+sx>22 && ex+sx<width-22) ex+=sx;
    if(ey+sy>22 && ey+sy<height-22) ey+=sy;
    sizeX();
    colorx();
    fill(colorred, colorgreen, colorblue);
    shapeX();
  }
}
//--------------------------各種軌跡
void line1(){
  if(move==0){//不移動
    sizeX();
    colorx();
    fill(colorred, colorgreen, colorblue);   
    shapeX();
    movex++;
    if(movex>movey){
      if(score==sc){//訓練結束
        score = 0;
        statu = st;
        sec = millis() - presec + sec;
        if(player!=null) player.pause();
        if(sec<60000)seco = sec/1000;//計算時間
        else if(sec<3600000){
          seco = (sec/1000)%60;
          minu = (sec/1000)/60;
        }
      }
      else{
        movex = 0;
        move = 1;
        m = n;
        player.pause();
      }
    }
  }
  if(move==1){//移動
    if(range>0){
      range--;
    }
    else{
      sx = step[bu][0];
      sy = step[bu][1];
      range = step[bu][2];
      bu++;
      if (bu>time) bu=1;
    }
    if(ex+sx>40 && ex+sx<width-40) ex+=sx;
    if(ey+sy>40 && ey+sy<height-40) ey+=sy;
    sizeX();
    colorx();
    fill(colorred, colorgreen, colorblue);
    shapeX();
  }
}
//-------------------------各種速度
void speedx(){
  if(speedy==0){
    time=Integer.valueOf(buf[0]).intValue();     
    for(int i=1;i<=time;i++){
      strin = new StringTokenizer(buf[i]);
      step[i][0]=Integer.valueOf(strin.nextToken()).intValue()*width/1280/2; 
      step[i][1]=Integer.valueOf(strin.nextToken()).intValue()*height/720/2;
      step[i][2]=Integer.valueOf(strin.nextToken()).intValue()*2;
    }
  }
  if(speedy==1){
    time=Integer.valueOf(buf[0]).intValue();     
    for(int i=1;i<=time;i++){
      strin = new StringTokenizer(buf[i]);
      step[i][0]=Integer.valueOf(strin.nextToken()).intValue()*width/1280; 
      step[i][1]=Integer.valueOf(strin.nextToken()).intValue()*height/720;
      step[i][2]=Integer.valueOf(strin.nextToken()).intValue();
    }
  }
  if(speedy==2){
    time=Integer.valueOf(buf[0]).intValue();     
    for(int i=1;i<=time;i++){
      strin = new StringTokenizer(buf[i]);
      step[i][0]=Integer.valueOf(strin.nextToken()).intValue()*width/1280*2; 
      step[i][1]=Integer.valueOf(strin.nextToken()).intValue()*height/720*2;
      step[i][2]=Integer.valueOf(strin.nextToken()).intValue()/2;
    }
  }
}
//--------------------操作模式
void touchmode(){
   if((abs(abs(brightestX)-width*0.43)+abs(brightestY-height*0.4)<touchrange)
   ||(abs(abs(brightestX)-width*0.5)+abs(brightestY-height*0.4)<touchrange)
   ||(abs(abs(brightestX)-width*0.57)+abs(brightestY-height*0.4)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        a = b = c = d = e = 0 ;
        o = p;
        q = r;
        statu = st;//進視訊
      }
    }
  }
   if((abs(abs(brightestX)-width*0.43)+abs(brightestY-height*0.65)<touchrange)
   ||(abs(abs(brightestX)-width*0.5)+abs(brightestY-height*0.65)<touchrange)
   ||(abs(abs(brightestX)-width*0.57)+abs(brightestY-height*0.65)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        a = b = c = d = e = 0 ;
        o = p;
        q = r;
        statu = 0;//回首頁
        detect = false;
      }
    }
  }
}
//------------------------首頁
void touchmenu(){
  if((abs(abs(brightestX)-width*0.13)+abs(brightestY-height*0.81)<touchrange)
   ||(abs(abs(brightestX)-width*0.2)+abs(brightestY-height*0.81)<touchrange)
   ||(abs(abs(brightestX)-width*0.27)+abs(brightestY-height*0.81)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        a = b = c = d = e = 0 ;
        o = p;
        q = r;
        statu = 10;//開始
        reset();
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.43)+abs(brightestY-height*0.81)<touchrange)
   ||(abs(abs(brightestX)-width*0.5)+abs(brightestY-height*0.81)<touchrange)
   ||(abs(abs(brightestX)-width*0.57)+abs(brightestY-height*0.81)<touchrange)){
    q--;
    if (q<0){
      b = 1;
      o--;
      if(o<0){
        a = b = c = d = e = 0 ;
        o = p;
        q = r;
        statu = st;//選項
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.81)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.81)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.81)<touchrange)){
    q--;
    if (q<0){
      c = 1;
      o--;
      if(o<0){
        a = b = c = d = e = 0 ;
        o = p;
        q = r;
        exit();//離開
      }
    }
  }
  else{
    a = b = c = d = e = f = g = h = 0;
    q = r;
  }
}
//---------------------換感應顏色
void touchdc(){
  if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.49)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.49)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.49)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        dc = 0;//紅色
        detect = true;
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = st;
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.67)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.67)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.67)<touchrange)){
    q--;
    if (q<0){
      b = 1;
      o--;
      if(o<0){
        dc = 1;//綠色
        detect = true;
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = st;
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.84)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.84)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.84)<touchrange)){
    q--;
    if (q<0){
      c = 1;
      o--;
      if(o<0){
        dc = 2;//藍色
        detect = true;
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = st;
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.86)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.9)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.94)+abs(brightestY-height*0.24)<touchrange)){
    q--;
    if (q<0){
      e = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;      
        statu = 15;//上一頁
      }
    }
  }
  else{
    a = b = c = d = e = f = g = h = 0;
    q = r;
  }
}
//---------------------------換形狀.顏色
void touchII(){
  if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.53)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.53)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.53)<touchrange)){
    f = 1;
    m--;
    if (m<0){
      a = 1;
      o--;
      if(o<0){
        if(statu==1)shapey = 0;
        if(statu==2)colory = 0;
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        m = n;
        statu = st;
        bossx = bossy = bossz = 0;//關閉隱藏關卡
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.76)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.76)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.76)<touchrange)){
    g = 1;
    m--;
    if (m<0){
      b = 1;
      o--;
      if(o<0){
        if(statu==1)shapey = 1;
        if(statu==2)colory = 1;
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        m = n;
        statu = st;
        bossx = bossy = bossz = 0;//關閉隱藏關卡
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.68)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.72)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.76)+abs(brightestY-height*0.24)<touchrange)){
    q--;
    if (q<0){
      d = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;      
        statu--;//上一頁
        bossx = bossy = bossz = 0;//關閉隱藏關卡
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.86)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.9)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.94)+abs(brightestY-height*0.24)<touchrange)){
    q--;
    if (q<0){
      e = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;      
        statu = 0;
        bossx = bossy = bossz = 0;//關閉隱藏關卡
      }
    }
  }
  else if(abs(abs(brightestX)-width*0.156)+abs(brightestY-height*0.312)<touchrange){
    bossx = 1;
  }
  else if(mousePressed&&(mouseButton == CENTER)&&(abs(mouseX-width*0.156)+abs(mouseY-height*0.312))<touchrange){
    bossy = 1;
  }
  else if(keyPressed){
    if(key=='B')bossz = 1;
  }
  else{
   a = b = c = d = e = f = g = h = 0;
   m = n;
   q = r;
  }
}
//-----------------換尺寸.軌跡.速度.音樂.次數
void touchIII(){
  if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.49)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.49)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.49)<touchrange)){
    f = 1;
    m--;
    if (m<0){
      a = 1;
      o--;
      if(o<0){
        if(statu==3)sizey = 0;
        if(statu==4)buf=loadStrings("line1.txt");
        if(statu==5)speedy = 0;
        if(statu==6)music = "mus1.mp3";
        if(statu==7)sc = 3;
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        m = n;
        statu = st;
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.67)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.67)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.67)<touchrange)){
    g = 1;
    m--;
    if (m<0){
      b = 1;
      o--;
      if(o<0){
        if(statu==3)sizey = 1;
        if(statu==4)buf=loadStrings("line2.txt");
        if(statu==5)speedy = 1;
        if(statu==6)music = "mus2.mp3";
        if(statu==7)sc = 5;
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        m = n;
        statu = st;
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.73)+abs(brightestY-height*0.84)<touchrange)
   ||(abs(abs(brightestX)-width*0.8)+abs(brightestY-height*0.84)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.84)<touchrange)){
    h = 1;
    m--;
    if (m<0){
      c = 1;
      o--;
      if(o<0){
        if(statu==3)sizey = 2;
        if(statu==4)buf=loadStrings("line3.txt");
        if(statu==5)speedy = 2;
        if(statu==6)music = "mus3.mp3";
        if(statu==7)sc = 7;
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        m = n;
        statu = st;
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.68)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.72)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.76)+abs(brightestY-height*0.24)<touchrange)){
    q--;
    if (q<0){
      d = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu--;//上一頁
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.86)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.9)+abs(brightestY-height*0.24)<touchrange)
   ||(abs(abs(brightestX)-width*0.94)+abs(brightestY-height*0.24)<touchrange)){
    q--;
    if (q<0){
      e = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;      
        statu = 0;
      }
    }
  }
  else{
    a = b = c = d = e = f = g = h = 0;
    m = n;
    q = r;
  }
}
//----------------確認開始
void touchstart(){
  if((abs(abs(brightestX)-width*0.43)+abs(brightestY-height*0.28)<touchrange)
   ||(abs(abs(brightestX)-width*0.5)+abs(brightestY-height*0.28)<touchrange)
   ||(abs(abs(brightestX)-width*0.57)+abs(brightestY-height*0.28)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = st;//確認進入下一頁
        reset();
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.43)+abs(brightestY-height*0.52)<touchrange)
   ||(abs(abs(brightestX)-width*0.5)+abs(brightestY-height*0.52)<touchrange)
   ||(abs(abs(brightestX)-width*0.57)+abs(brightestY-height*0.52)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = 7;//上一頁
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.43)+abs(brightestY-height*0.73)<touchrange)
   ||(abs(abs(brightestX)-width*0.5)+abs(brightestY-height*0.73)<touchrange)
   ||(abs(abs(brightestX)-width*0.57)+abs(brightestY-height*0.73)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = 0;//回首頁
      }
    }
  }
  else {
    q = r;
    rs = -1;
  }
}
//--------------------觸碰物體
void touchX(){
  if (abs(abs(brightestX)-ex)+abs(brightestY-ey)<si){//接觸發生
    o--;
    if (o<0){
      o = p;
      if (tc==false){
        tc = true;
        move = 0;
        if(player!=null) player.close();
        player = minim.loadFile(music, 512);
        player.loop();
        score++;
      }
      else{
        if (move==1){
          move = 0;
          player.play();
          score++;
        }
      }
    }
  }
  else if (keyPressed) {//暫停
    if(key == ' '){
      rs = 12;//暫停
      alphax = true;//控制暫停頁面背景
      if(player!=null) player.pause();
    }
  }
}
//------------------訓練結束
void touchgameover(){
   if((abs(abs(brightestX)-width*0.62)+abs(brightestY-height*0.27)<touchrange)
   ||(abs(abs(brightestX)-width*0.66)+abs(brightestY-height*0.27)<touchrange)
   ||(abs(abs(brightestX)-width*0.7)+abs(brightestY-height*0.27)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = 10;//開始
        reset();
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.83)+abs(brightestY-height*0.27)<touchrange)
   ||(abs(abs(brightestX)-width*0.87)+abs(brightestY-height*0.27)<touchrange)
   ||(abs(abs(brightestX)-width*0.91)+abs(brightestY-height*0.27)<touchrange)){
    q--;
    if (q<0){
      e = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = 0;//回首頁
      }
    }
  }
  else{
    a = b = c = d = e = f = g = h = 0 ;
    q = r;
  }
}
//--------------------------------------暫停頁面
void touchpause(){
  if (keyPressed) {//繼續
    if(key == ' '){
      image(menubutton[0][0], width*0.317, height*0.18, width*0.375, height*0.25);
      rs = 11;//開始
      if(boss==1)reset();
      if(player!=null&&move==0) player.play();
    }
  }
  if((mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.43)+abs(mouseY-height*0.3))<touchrange)
   ||(mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.5)+abs(mouseY-height*0.3))<touchrange)
   ||(mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.57)+abs(mouseY-height*0.3))<touchrange)){
    image(menubutton[0][0], width*0.317, height*0.18, width*0.375, height*0.25);
    rs = 4;//不重置開始
    if(boss==1)reset();
    if(player!=null&&move==0) player.play();
  }
  if((mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.43)+abs(mouseY-height*0.52))<touchrange)
   ||(mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.5)+abs(mouseY-height*0.52))<touchrange)
   ||(mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.57)+abs(mouseY-height*0.52))<touchrange)){
    image(menubutton[0][1], width*0.317, height*0.396, width*0.375, height*0.25);
    rs = 5;//回選項
  }
  if((mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.43)+abs(mouseY-height*0.73))<touchrange)
   ||(mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.5)+abs(mouseY-height*0.73))<touchrange)
   ||(mousePressed&&(mouseButton == LEFT)&&(abs(mouseX-width*0.57)+abs(mouseY-height*0.73))<touchrange)){
    image(menubutton[2][1], width*0.317, height*0.6, width*0.375, height*0.25);
    rs = 2;//回首頁
  }
}
//------------測試頁面
void touchtest(){
  if((mousePressed && (mouseButton == LEFT)&&(abs(mouseX-width*0.81)+abs(mouseY-height*0.125))<touchrange)
   ||(mousePressed && (mouseButton == LEFT)&&(abs(mouseX-width*0.85)+abs(mouseY-height*0.125))<touchrange)
   ||(mousePressed && (mouseButton == LEFT)&&(abs(mouseX-width*0.89)+abs(mouseY-height*0.125))<touchrange)){
    image(back[1][0], -width*0.738, height*0.07, -width*0.25, height*0.125);
    rs = 1;//回選項
    detect = false;
  }
  else if((abs(abs(brightestX)-width*0.81)+abs(brightestY-height*0.125)<touchrange)
   ||(abs(abs(brightestX)-width*0.85)+abs(brightestY-height*0.125)<touchrange)
   ||(abs(abs(brightestX)-width*0.89)+abs(brightestY-height*0.125)<touchrange)){
    q--;
    if (q<0){
      d = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = 13;//回選項
        detect = false;
      }
    }
  }
  else if((abs(abs(brightestX)-width*0.43)+abs(brightestY-height*0.77)<touchrange)
   ||(abs(abs(brightestX)-width*0.5)+abs(brightestY-height*0.77)<touchrange)
   ||(abs(abs(brightestX)-width*0.57)+abs(brightestY-height*0.77)<touchrange)){
    q--;
    if (q<0){
      a = 1;
      o--;
      if(o<0){
        a = b = c = d = e = f = g = h = 0 ;
        o = p;
        q = r;
        statu = st;//確認進入下一頁
      }
    }
  }
  else{
    a = b = c = d = e = f = g = h = 0 ;
    q = r;
    rs = -1;
  }
}
//---------------------統計時間
void gameover(){
  secdigitinones = seco % 10;
  secdigitintens = seco / 10;
  mindigitinones = minu % 10;
  mindigitintens = minu / 10;
}

void mouseReleased(){
  if(rs==0)statu = st;//下一頁
  if(rs==1)statu--;//上一頁
  if(rs==2)statu = 0;//回首頁
  if(rs==3){
    reset();
    statu = 10;//開始
  }
  if(rs==4)statu = 10;//暫停頁不重置開始
  if(rs==5)statu = 1;//回選項
  if(rs==10)exit();//離開
  else{rs = -1;}
  rs = -1;
}

void keyReleased(){
  if(rs==11){
    statu = 10;//開始
    presec = millis();
  }
  if(rs==12){
    statu = 12;//暫停
    sec = millis() - presec + sec;
  }
  if(bossx==1&&bossy==1&&bossz==1){
    reset();
    statu = 99;
  }
  else{rs = -1;}
  rs = -1;
}
//-----------------重置非選項參數
void reset(){
  speedx();
  ex = width/2;
  ey = height/10;
  range = 0;
  bu = 1;
  tc = false;
  move = 1;
  score = 0;
  presec = millis();
  sec = seco = minu = 0;
  secdigitinones = secdigitintens = mindigitinones = mindigitintens = 0;
  boss = bossx = bossy = bossz = 0;
  movex = 0;
}

void stop()
{
  player.close();
  minim.stop();
  super.stop();
}