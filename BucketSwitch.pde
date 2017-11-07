/*
 * ***** BEGIN GPL LICENSE BLOCK *****
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * The Original Code is Copyright (C) 2017 Marcelo "Tanda" Cerviño. http://lodetanda.blogspot.com/ 
 * All rights reserved.
 *
 * Contributor(s): Matías Cerviño (idea and testing) https://twitter.com/MatiasmacSD
 *
 * ***** END GPL LICENSE BLOCK *****
 */
 
import beads.*;
import org.jaudiolibs.beads.*;

AudioContext ac;
Glide ga;
Gain gainput;
UGen inputs;

PrintWriter write;
BufferedReader reader;

PImage bg1;
PImage bg2;

boolean on = false;

int samples[] = new int[] {16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192};
int nsamples;

int bit[] = new int[] {8, 16, 24, 32, 64};
int nbit;

int hz[] = new int[] {22050, 32000, 44100, 48000, 88200, 96000, 192000};
int nhz;

int switchtime;

void setup()
{
  size(250, 250); 
  background(50);
  noLoop();
  textAlign(CENTER);

  bg1 = requestImage("bg1.png");
  bg2 = requestImage("bg2.png");

  loadSettings();

  ac = new AudioContext(new AudioServerIO.Jack("BucketSwitch"), samples[nsamples], new IOAudioFormat(hz[nhz], bit[nbit], 2, 2));

  ga  = new Glide(ac, 1, switchtime);
  inputs = ac.getAudioInput();
  gainput = new Gain(ac, 2, ga);
  gainput.addInput(inputs);
  ac.out.addInput(gainput);
  ac.start();
}

void draw()
{
  background(50);

  fill(200, 150, 100);
  textSize(50);
  text("(X)", width / 2, 90);

  if (on) image(bg2, 0, 0);
  else image(bg1, 0, 0);

  textSize(12);
  text(switchtime+" ms", width / 2, 150);
  text("-SwitchTime+", width / 2, 160);
  text("-"+hz[nhz]+" Hz+", 40, 240);
  text("-"+bit[nbit]+" bit+", 112, 240);
  text("-"+samples[nsamples]+" Samples+", 195, 240);
  fill(200, 50, 50);
  text(">SAVE Settings<", width / 2, 215);
  fill(120, 120, 120);
  textSize(9);
  text("'JACK server' configuration -Need Save and Restart-", width / 2, 225);
  text("BUCKETSWITCH v1.0", width / 2, 10);
}

void mousePressed() {
  if (switch_()) {
    ga.setValue(0);
    on = true;
  }
  if (save_()) {
    saveSettings();
    exit();
  }
  if (switchTimeL_()) {
    switchtime = constrain(switchtime -= 10, 0, 1000);
    ga.setGlideTime(switchtime);
  }
  if (switchTimeR_()) {
    switchtime = constrain(switchtime += 10, 0, 1000);
    ga.setGlideTime(switchtime);
  }
  if (hzL_()) {
    nhz = constrain(nhz -= 1, 0, 6);
  }
  if (hzR_()) {
    nhz = constrain(nhz += 1, 0, 6);
  }
  if (samplesL_()) {
    nsamples = constrain(nsamples -= 1, 0, 9);
  }
  if (samplesR_()) {
    nsamples = constrain(nsamples += 1, 0, 9);
  }
  if (bitL_()) {
    nbit = constrain(nbit -= 1, 0, 4);
  }
  if (bitR_()) {
    nbit = constrain(nbit += 1, 0, 4);
  }
  if (github_()) {
    link("https://github.com/eLeDeTe-LoDeTanda/BucketSwitch");
  }
  redraw();
}

void mouseReleased() {
  ga.setValue(1);
  on = false;
  redraw();
}

void keyPressed()
{
  ga.setValue(0);
  on = true;
  redraw();
}

void keyReleased()
{
  ga.setValue(1);
  on = false;
  redraw();
}

/*###########################################*/

void saveSettings()
{
  write = createWriter(sketchPath("BucketSwitch.settings"));
  write.println("[JACK Settigs]");
  write.println(hz[nhz]+" hz");
  write.println(bit[nbit]+" bit");
  write.println(samples[nsamples]+" samples");
  write.println("----------------------");
  write.println("[SWITCH TIME]");
  write.println(switchtime+" ms");
  write.println("----------------------");

  write.flush();
  write.close();
}

void loadSettings()
{
  int val;
  String lines[] = loadStrings(sketchPath("BucketSwitch.settings"));
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("[JACK Settigs]")) {
      val = int(trim(lines[i+1].substring(0, lines[i+1].lastIndexOf("hz"))));
      for (int e = 0; e < hz.length; e++) {
        if (hz[e] == val) { 
          nhz = e;
          break;
        }
      }
      val = int(trim(lines[i+2].substring(0, lines[i+2].lastIndexOf("bit"))));
      for (int e = 0; e < bit.length; e++) {
        if (bit[e] == val) { 
          nbit = e;
          break;
        }
      }
      val = int(trim(lines[i+3].substring(0, lines[i+3].lastIndexOf("samples"))));
      for (int e = 0; e < samples.length; e++) {
        if (samples[e] == val) { 
          nsamples = e;
          break;
        }
      }
    } else if (lines[i].contains("[SWITCH TIME]")) {
      switchtime = int(trim(lines[i+1].substring(0, lines[i+1].lastIndexOf("ms"))));
    }
  }
}

/*###########################################*/

boolean switch_() 
{
  return  (mouseX > 80 && mouseX < 160 && mouseY > 40 && mouseY < 110);
}

boolean switchTimeL_() 
{
  return  (mouseX > 70 && mouseX < 115 && mouseY > 140 && mouseY < 165);
}
boolean switchTimeR_() 
{
  return  (mouseX > 130 && mouseX < 175 && mouseY > 140 && mouseY < 165);
}

boolean save_() 
{
  return  (mouseX > 35 && mouseX < 220 && mouseY > 200 && mouseY < 220);
}

boolean hzL_() 
{
  return  (mouseX > 5 && mouseX < 40 && mouseY > 230 && mouseY < 240);
}
boolean hzR_() 
{
  return  (mouseX > 40 && mouseX < 75 && mouseY > 230 && mouseY < 240);
}

boolean bitL_() 
{
  return  (mouseX > 85 && mouseX < 105 && mouseY > 230 && mouseY < 240);
}
boolean bitR_() 
{
  return  (mouseX > 105 && mouseX < 135 && mouseY > 230 && mouseY < 240);
}

boolean samplesL_() 
{
  return  (mouseX > 145 && mouseX < 195 && mouseY > 230 && mouseY < 240);
}
boolean samplesR_() 
{
  return  (mouseX > 195 && mouseX < 245 && mouseY > 230 && mouseY < 240);
}

boolean github_() 
{
  return  (mouseX > 0 && mouseX < 250 && mouseY > 0 && mouseY < 10);
}