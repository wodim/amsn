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
  m       �null      � ��  RSystem Events.app�
�      |���0���`�MxԿ���    �L�          sevs   alis    |  Jaguar                     ��[�H+    RSystem Events.app                                               ���H�        ����  	                CoreServices    ���      ��)      R  Y  X  4Jaguar:System:Library:CoreServices:System Events.app  $  S y s t e m   E v e n t s . a p p    J a g u a r  -System/Library/CoreServices/System Events.app   / ��  ��      
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
 / k   6 | 9 9  : ;
 : r   6 = < =
 < n  6 ; > ?
 > 1   9 ;��
�� 
pLoc
 ? 1   6 9��
�� 
pTrk
 = o      ���� 
0 	firstpath   ;  @ A
 @ l  > >�� B��   B z tApple do not allow us to get path from iPod, so I verify to know if we get a value from the current track's location    A  C D
 C Z   > [ E F�� G
 E >  > C H I
 H o   > ?���� 
0 	firstpath  
 I m   ? B��
�� 
msng
 F r   F Q J K
 J n   F M L M
 L 1   I M��
�� 
psxp
 M o   F I���� 0 yo  
 K o      ���� 
0 	finalpath  ��  
 G r   T [ N O
 N m   T W P P 
 iPod   
 O o      ���� 
0 	finalpath   D  Q R
 Q L   \ z S
 S b   \ y T U
 T b   \ u V W
 V b   \ q X Y
 X b   \ m Z [
 Z b   \ g \ ]
 \ n   \ c ^ _
 ^ 1   _ c��
�� 
pArt
 _ 1   \ _��
�� 
pTrk
 ] m   c f ` ` 	  -    
 [ n   g l a b
 a 1   j l��
�� 
pnam
 b 1   g j��
�� 
pTrk
 Y m   m p c c  ?*   
 W o   q t���� 
0 	finalpath  
 U m   u x d d  *Z    R  e��
 e l  { {�� f��   f . (if iTunes is paused, return that message   ��   0  g h
 g =   � i j
 i 1    ���
�� 
pPlS
 j m   � ���
�� ePlSkPSp h  k l
 k k   � � m m  n o
 n L   � � p
 p m   � � q q  Paused    o  r��
 r l  � ��� s��   s / )if iTunes is stopped, return that message   ��   l  t u
 t =  � � v w
 v 1   � ���
�� 
pPlS
 w m   � ���
�� ePlSkPSS u  x��
 x L   � � y
 y m   � � z z  iTunes is Stopped   ��  ��  ��  
 ( m     { {�null     � ��  [
iTunes.app���(�"D�
�      :��ᐿ����MxԿ��0    �L�          hook   alis    :  Jaguar                     ��[�H+    [
iTunes.app                                                      �n��I        ����  	                Applications    ���      ��܉      [  Jaguar:Applications:iTunes.app   
 i T u n e s . a p p    J a g u a r  Applications/iTunes.app   / ��   &  |��
 | l  � ��� }��   }  if iTunes is not open   ��  ��  
 ! L   � � ~
 ~ c   � �  �
  m   � � � � 	 Off   
 � m   � ���
�� 
TEXT��     ���
 � l     ������  ��  ��       �� � ����� P��   � ��������
�� .aevtoappnull  �   � ****�� 0 itunes iTunes�� 
0 	firstpath  �� 
0 	finalpath   � �� ����� � ���
�� .aevtoappnull  �   � ****
 � k     � � �   � �  ����  ��  ��   �   �  �� ��� ���� {������������������������ P�� ` c d�� q�� z ���
�� 
pcap �  
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
pLoc�� 
0 	firstpath  
�� 
msng�� 0 yo  
�� 
psxp�� 
0 	finalpath  
�� 
pArt
�� ePlSkPSp
�� ePlSkPSS
�� 
TEXT�� �� *�-�[�,\Z�81j E�UO�j �� �*�,� 	 *�,�,� �& K*�,�,E�O�a  _ a ,E` Y 	a E` O*�,a ,a %*�,�,%a %_ %a %OPY '*�,a   a OPY *�,a   	a Y hUOPY 
a a &�� 
�� 
msngascr  ��ޭ