FasdUAS 1.101.10   ��   ��  
  k           
  l     �� ��      by Edgar C. Rodriguez       	
  l     �� 
��   
 A ;iTunes script to get Path and Name of current track playing    	   
  l     
��
 
 O       
  r      
  l    ��
  I   �� ��
�� .corecnte****       ****
  l    ��
  6     
  2   ��
�� 
pcap
  l    ��
  =     
  1   	 ��
�� 
pnam
  m        iTunes   ��  ��  ��  ��  
  o      ���� 0 itunes iTunes
  m       �null     ߀��  RSystem Events.app�L��� 80����   @ ��   )       �(�K� ���  �sevs   alis    |  Jaguar                     ��[�H+    RSystem Events.app                                               ���H�        ����  	                CoreServices    ���      ��)      R  Y  X  4Jaguar:System:Library:CoreServices:System Events.app  $  S y s t e m   E v e n t s . a p p    J a g u a r  -System/Library/CoreServices/System Events.app   / ��  ��      
  l   � ��
  Z    �   �� !
  ?    " #
 " o    ���� 0 itunes iTunes
 # m    ����  
   k    � $ $  % &
 % O    � ' (
 ' k   " � ) )  * +
 * l  " "�� ,��   , S Mif iTunes is playing, return the artist, the song name and the path (in Unix)    +  -��
 - Z   " � . / 0��
 . F   " 3 1 2
 1 =  " ' 3 4
 3 1   " %��
�� 
pPlS
 4 m   % &��
�� ePlSkPSP
 2 =  * 1 5 6
 5 n   * / 7 8
 7 m   - /��
�� 
pcls
 8 1   * -��
�� 
pTrk
 6 m   / 0��
�� 
cFlT
 / k   6 ` 9 9  : ;
 : r   6 = < =
 < n  6 ; > ?
 > 1   9 ;��
�� 
pLoc
 ? 1   6 9��
�� 
pTrk
 = o      ���� 0 yo   ;  @ A
 @ L   > ^ B
 B b   > ] C D
 C b   > Y E F
 E b   > S G H
 G b   > O I J
 I b   > I K L
 K n   > E M N
 M 1   A E��
�� 
pArt
 N 1   > A��
�� 
pTrk
 L m   E H O O 	  -    
 J n   I N P Q
 P 1   L N��
�� 
pnam
 Q 1   I L��
�� 
pTrk
 H m   O R R R  ?*   
 F n   S X S T
 S 1   T X��
�� 
psxp
 T o   S T���� 0 yo  
 D m   Y \ U U  *Z    A  V��
 V l  _ _�� W��   W . (if iTunes is paused, return that message   ��   0  X Y
 X =  c j Z [
 Z 1   c f��
�� 
pPlS
 [ m   f i��
�� ePlSkPSp Y  \ ]
 \ k   m s ^ ^  _ `
 _ L   m q a
 a m   m p b b  iTunes is Paused    `  c��
 c l  r r�� d��   d / )if iTunes is stopped, return that message   ��   ]  e f
 e =  v } g h
 g 1   v y��
�� 
pPlS
 h m   y |��
�� ePlSkPSS f  i��
 i L   � � j
 j m   � � k k  iTunes is Stopped   ��  ��  ��  
 ( m     l l�null     � ��  [
iTunes.app�۠� �0�L��� 80����    ��,   )       �(�K� ���� �hook   alis    :  Jaguar                     ��[�H+    [
iTunes.app                                                      �n��I        ����  	                Applications    ���      ��܉      [  Jaguar:Applications:iTunes.app   
 i T u n e s . a p p    J a g u a r  Applications/iTunes.app   / ��   &  m��
 m l  � ��� n��   n  if iTunes is not open   ��  ��  
 ! L   � � o
 o c   � � p q
 p m   � � r r  
iTunes is off   
 q m   � ���
�� 
TEXT��     s��
 s l     ������  ��  ��       �� t u�� v����   t ��������
�� .aevtoappnull  �   � ****�� 0 itunes iTunes�� 0 yo  ��   u �� w���� x y��
�� .aevtoappnull  �   � ****
 w k     � z z   { {  ����  ��  ��   x   y  �� |�� ���� l������������������ O R�� U�� b�� k r��
�� 
pcap |  
�� 
pnam
�� .corecnte****       ****�� 0 itunes iTunes
�� 
pPlS
�� ePlSkPSP
�� 
pTrk
�� 
pcls
�� 
cFlT
�� 
bool
�� 
pLoc�� 0 yo  
�� 
pArt
�� 
psxp
�� ePlSkPSp
�� ePlSkPSS
�� 
TEXT�� �� *�-�[�,\Z�81j E�UO�j r� h*�,� 	 *�,�,� �& /*�,�,E�O*�,a ,a %*�,�,%a %�a ,%a %OPY '*�,a   a OPY *�,a   	a Y hUOPY 
a a &��  v
alis    
   Jaguar                     ��[�H+   ��Discour-Dr-Zylberberg.mp3                                       ��k�6MPEGTVOD����  	                
Album inconnu     ���      �k��     �� �� �S �M  ��  �w  �  gJaguar:Users:gagnonje:Music:iTunes:iTunes Music:Artiste inconnu:Album inconnu:Discour-Dr-Zylberberg.mp3   4  D i s c o u r - D r - Z y l b e r b e r g . m p 3    J a g u a r  `Users/gagnonje/Music/iTunes/iTunes Music/Artiste inconnu/Album inconnu/Discour-Dr-Zylberberg.mp3  /    ��  ��   ascr  
��ޭ