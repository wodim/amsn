FasdUAS 1.101.10   ��   ��    k             l     �� ��      by Jerome Gagnon Voyer       	  l     �� 
��   
 < 6with the help of Edgar C. Rodriguez and Daniel Buenfil    	     l     �� ��    8 2Thanks to Doug Adams for the part about cover arts         l     �� ��    = 7Get more free AppleScripts and info on writing your own         l     �� ��    ' !at Doug's AppleScripts for iTunes         l     �� ��    ) #http://www.malcolmadams.com/itunes/         l     �� ��    ] WiTunes script to get Path and Name of current track playing and write it to a text file         l     ������  ��        l     ������  ��        l      ��   O      ! " ! r     # $ # l    %�� % I   �� &��
�� .corecnte****       **** & l    '�� ' 6    ( ) ( 2   ��
�� 
pcap ) l    *�� * =    + , + 1   	 ��
�� 
pnam , m     - -  iTunes   ��  ��  ��  ��   $ o      ���� 0 itunes iTunes " m      . .�null     ߀��  System Events.app�a�@���0���    N�   )       �2(�`鈿��POsevs   alis    |  MacOSX                     ���H+    System Events.app                                                i�c��        ����  	                CoreServices    �ʹ      �c��          
  4MacOSX:System:Library:CoreServices:System Events.app  $  S y s t e m   E v e n t s . a p p    M a c O S X  -System/Library/CoreServices/System Events.app   / ��  ��     / 0 / l     ������  ��   0  1 2 1 l  � 3�� 3 Z   � 4 5�� 6 4 ?    7 8 7 o    ���� 0 itunes iTunes 8 m    ����   5 k   � 9 9  : ; : r    ! < = < m     > >       = o      ���� 0 artfile   ;  ? @ ? O   "� A B A k   &� C C  D E D Z   &� F G H�� F =  & + I J I 1   & )��
�� 
pPlS J m   ) *��
�� ePlSkPSP G k   .� K K  L M L r   . 1 N O N m   . / P P 
 Play    O o      ���� 
0 status   M  Q R Q Z   2� S T U�� S =  2 ; V W V n   2 7 X Y X m   5 7��
�� 
pcls Y 1   2 5��
�� 
pTrk W m   7 :��
�� 
cURT T k   > Y Z Z  [ \ [ r   > G ] ^ ] n   > C _ ` _ 1   A C��
�� 
pnam ` 1   > A��
�� 
pTrk ^ o      ���� 0 asong aSong \  a b a r   H O c d c m   H K e e       d o      ���� 0 aart aArt b  f g f r   P U h i h m   P Q����   i o      ���� 0 	finalpath   g  j�� j r   V Y k l k m   V W����   l o      ���� 0 artfile  ��   U  m n m =  \ e o p o n   \ a q r q m   _ a��
�� 
pcls r 1   \ _��
�� 
pTrk p m   a d��
�� 
cShT n  s t s k   h � u u  v w v r   h q x y x n   h m z { z 1   k m��
�� 
pnam { 1   h k��
�� 
pTrk y o      ���� 0 asong aSong w  | } | r   r } ~  ~ n   r y � � � 1   u y��
�� 
pArt � 1   r u��
�� 
pTrk  o      ���� 0 aart aArt }  � � � r   ~ � � � � m   ~ ����   � o      ���� 0 	finalpath   �  ��� � r   � � � � � m   � �����   � o      ���� 0 artfile  ��   t  � � � =  � � � � � n   � � � � � m   � ���
�� 
pcls � 1   � ���
�� 
pTrk � m   � ���
�� 
cCDT �  � � � k   � � � �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
pnam � 1   � ���
�� 
pTrk � o      ���� 0 asong aSong �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
pArt � 1   � ���
�� 
pTrk � o      ���� 0 aart aArt �  � � � r   � � � � � m   � �����   � o      ���� 0 	finalpath   �  ��� � r   � � � � � m   � �����   � o      ���� 0 artfile  ��   �  � � � =  � � � � � n   � � � � � m   � ���
�� 
pcls � 1   � ���
�� 
pTrk � m   � ���
�� 
cFlT �  ��� � k   �~ � �  � � � r   � � � � � c   � � � � � n   � � � � � 1   � ���
�� 
pnam � 1   � ���
�� 
pTrk � m   � ���
�� 
ctxt � o      ���� 0 asong aSong �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
pArt � 1   � ���
�� 
pTrk � o      ���� 0 aart aArt �  � � � r   � � � � � n  � � � � � 1   � ���
�� 
pLoc � 1   � ���
�� 
pTrk � o      ���� 0 	firstpath   �  � � � Z   � � ��� � � >  � � � � � o   � ����� 0 	firstpath   � m   � ���
�� 
msng � r   � � � � c   � � � � � n   � � � � � 1   � ���
�� 
psxp � o   � ����� 0 	firstpath   � m   � ���
�� 
TEXT � o      ���� 0 	finalpath  ��   � r   � � � m  ����   � o      ���� 0 	finalpath   �  � � � l ������  ��   �  � � � l �� ���   �  Taking care of Artwork    �  � � � r   � � � 1  ��
�� 
pTrk � o      ���� 0 thetrack theTrack �  � � � Z  8 � ����� � G  . � � � >  � � � n   � � � m  ��
�� 
pcls � 1  ��
�� 
pTrk � m  ��
�� 
cFlT � =  * � � � n   ' � � � 2 #'��
�� 
cArt � 1   #��
�� 
pTrk � J  ')����   � k  14 � �  � � � l 11�� ���   � N Hmy alert_user_and_cancel("The selected track does not contain Artwork.")    �  ��� � r  14 � � � m  12����   � o      ���� 0 artfile  ��  ��  ��   �  � � � l 99������  ��   �  � � � r  9V � � � b  9R � � � l 9N ��� � I 9N�� � �
�� .earsffdralis        afdr � m  9<��
�� afdmasup � �� � �
�� 
from � m  ?B��
�� fldmfldu � �� ���
�� 
rtyp � m  EH��
�� 
TEXT��  ��   � m  NQ � �  amsn:plugins:    � o      ���� 0 artworkfolder artworkFolder �  � � � Q  Wb �  � k  ZU  r  Zn c  Zj l Zf	��	 n  Zf

 1  bf��
�� 
pPCT n  Zb 4  ]b��
�� 
cArt m  `a����  o  Z]�� 0 thetrack theTrack��   m  fi�~
�~ 
PICT o      �}�} 0 artworkdata artworkData  r  o� c  o l o{�| n  o{ 1  w{�{
�{ 
pFmt n  ow 4  rw�z
�z 
cArt m  uv�y�y  o  or�x�x 0 thetrack theTrack�|   m  {~�w
�w 
TEXT o      �v�v 0 artworkformat artworkFormat  Z  ���u E  �� !  o  ���t�t 0 artworkformat artworkFormat! m  ��"" 
 JPEG    r  ��#$# m  ��%% 
 .jpg   $ o      �s�s 0 	extension   &'& E  ��()( o  ���r�r 0 artworkformat artworkFormat) m  ��** 	 PNG   ' +�q+ r  ��,-, m  ��.. 
 .png   - o      �p�p 0 	extension  �q  �u   /0/ l ���o�n�o  �n  0 121 r  ��343 m  ��55  artworkitunes   4 o      �m�m 0 thename theName2 676 l ���l�k�l  �k  7 898 r  ��:;: c  ��<=< l ��>�j> b  ��?@? b  ��ABA o  ���i�i 0 artworkfolder artworkFolderB m  ��CC 
 temp   @ o  ���h�h 0 	extension  �j  = m  ���g
�g 
TEXT; o      �f�f "0 tempartworkfile tempartworkFile9 DED r  ��FGF c  ��HIH l ��J�eJ b  ��KLK b  ��MNM o  ���d�d 0 artworkfolder artworkFolderN o  ���c�c 0 thename theNameL o  ���b�b 0 	extension  �e  I m  ���a
�a 
TEXTG o      �`�` $0 finalartworkfile finalartworkFileE OPO l ���_�^�_  �^  P QRQ r  ��STS l ��U�]U I ���\VW
�\ .rdwropenshor       fileV o  ���[�[ "0 tempartworkfile tempartworkFileW �ZX�Y
�Z 
permX m  ���X�X �Y  �]  T o      �W�W 0 file_reference  R YZY I ��V[\
�V .rdwrwritnull���     ****[ o  ���U�U 0 artworkdata artworkData\ �T]^
�T 
wrat] m  ���S�S  ^ �R_`
�R 
refn_ o  ���Q�Q 0 file_reference  ` �Pa�O
�P 
as  a m  ��N
�N 
PICT�O  Z bcb I �Md�L
�M .rdwrclosnull���     ****d o  �K�K 0 file_reference  �L  c efe l �J�I�J  �I  f ghg I S�Hi�G
�H .sysoexecTEXT���     TEXTi b  Ojkj b  Clml b  ?non b  3pqp b  /rsr b  #tut b  vwv m  xx 	 cd    w n  yzy 1  �F
�F 
strqz l {�E{ n  |}| 1  �D
�D 
psxp} o  �C�C 0 artworkfolder artworkFolder�E  u l 	"~�B~ m  "  ;tail -c+223    �B  s n  #.��� 1  *.�A
�A 
strq� l #*��@� b  #*��� m  #&�� 
 temp   � o  &)�?�? 0 	extension  �@  q m  /2��  >    o n  3>��� l 	:>��>� 1  :>�=
�= 
strq�>  � l 3:��<� b  3:��� o  36�;�; 0 thename theName� o  69�:�: 0 	extension  �<  m m  ?B�� 
 ;rm    k n  CN��� l 	JN��9� 1  JN�8
�8 
strq�9  � l CJ��7� b  CJ��� m  CF�� 
 temp   � o  FI�6�6 0 	extension  �7  �G  h ��5� l TT�4�3�4  �3  �5    R      �2��1
�2 .ascrerr ****      � ****� o      �0�0 0 errm errM�1   k  ]b�� ��� l ]]�/��/  � ! close access file_reference   � ��� l ]]�.��.  � E ?return ("Unable to export Artwork from the selected track." & �   � ��� l ]]�-��-  �  	return & return & errM)   � ��� r  ]`��� m  ]^�,�,  � o      �+�+ 0 artfile  � ��� l aa�*�)�*  �)  � ��(� l aa�'�&�'  �&  �(   � ��%� Z  c~���$�� > cf��� o  cd�#�# 0 artfile  � m  de�"�"  � r  iv��� c  it��� n  ip��� 1  lp�!
�! 
psxp� o  il� �  $0 finalartworkfile finalartworkFile� m  ps�
� 
TEXT� o      �� 0 artfile  �$  � r  y~��� m  y|��      � o      �� 0 artfile  �%  ��  ��   R ��� l �����  �  � ��� r  ����� b  ����� b  ����� b  ����� b  ����� b  ����� b  ����� b  ����� b  ����� o  ���� 
0 status  � m  ����  
   � o  ���� 0 asong aSong� m  ����  
   � o  ���� 0 aart aArt� m  ����  
   � o  ���� 0 	finalpath  � m  ����  
   � o  ���� 0 artfile  � o      �
� 
ret � ��� l �����  �  � ��� L  ���� o  ���
� 
ret � ��� l �����  �  �   H ��� = ����� 1  ���
� 
pPlS� m  ���
� ePlSkPSp� ��� L  ���� m  ����  � ��� = ����� 1  ���
� 
pPlS� m  ���

�
 ePlSkPSS� ��	� L  ���� m  ����  �	  ��   E ��� l �����  �  �   B m   " #���null     � ��  *
iTunes.app��0�a���a� �f>`���P   N�4   )       �2(�`鈿�πOhook   alis    :  MacOSX                     ���H+    *
iTunes.app                                                      ;B�mFL        ����  	                Applications    �ʹ      �m8<      *  MacOSX:Applications:iTunes.app   
 i T u n e s . a p p    M a c O S X  Applications/iTunes.app   / ��   @ ��� l �����  �  if iTunes is not open   �  ��   6 k  ���� ��� L  ���� m  ����  � ��� l ��� ���   ��  �  ��   2 ��� l     ������  ��  � ���� l     ������  ��  ��       ������ >����  � ��������
�� .aevtoappnull  �   � ****�� 0 itunes iTunes�� 0 artfile  ��  � �����������
�� .aevtoappnull  �   � ****� k    ���  ��  1����  ��  ��  � ���� 0 errm errM� T .����� -���� >������� P���������� e������������������������������������������ �������������"%��*.5��C����������������������x�����������������������
�� 
pcap�  
�� 
pnam
�� .corecnte****       ****�� 0 itunes iTunes�� 0 artfile  
�� 
pPlS
�� ePlSkPSP�� 
0 status  
�� 
pTrk
�� 
pcls
�� 
cURT�� 0 asong aSong�� 0 aart aArt�� 0 	finalpath  
�� 
cShT
�� 
pArt
�� 
cCDT
�� 
cFlT
�� 
ctxt
�� 
pLoc�� 0 	firstpath  
�� 
msng
�� 
psxp
�� 
TEXT�� 0 thetrack theTrack
�� 
cArt
�� 
bool
�� afdmasup
�� 
from
�� fldmfldu
�� 
rtyp�� 
�� .earsffdralis        afdr�� 0 artworkfolder artworkFolder
�� 
pPCT
�� 
PICT�� 0 artworkdata artworkData
�� 
pFmt�� 0 artworkformat artworkFormat�� 0 	extension  �� 0 thename theName�� "0 tempartworkfile tempartworkFile�� $0 finalartworkfile finalartworkFile
�� 
perm
�� .rdwropenshor       file�� 0 file_reference  
�� 
wrat
�� 
refn
�� 
as  �� 
�� .rdwrwritnull���     ****
�� .rdwrclosnull���     ****
�� 
strq
�� .sysoexecTEXT���     TEXT�� 0 errm errM��  
�� 
ret 
�� ePlSkPSp
�� ePlSkPSS���� *�-�[�,\Z�81j E�UO�j��E�O��*�,� ��E�O*�,�,a    *�,�,E` Oa E` OjE` OjE�Y(*�,�,a   $*�,�,E` O*�,a ,E` OjE` OjE�Y�*�,�,a   $*�,�,E` O*�,a ,E` OjE` OjE�Y�*�,�,a  �*�,�,a &E` O*�,a ,E` O*�,a ,E` O_ a  _ a ,a &E` Y jE` O*�,E` O*�,�,a 
 *�,a  -jv a !& jE�Y hOa "a #a $a %a a & 'a (%E` )O _ a  k/a *,a +&E` ,O_ a  k/a -,a &E` .O_ .a / a 0E` 1Y _ .a 2 a 3E` 1Y hOa 4E` 5O_ )a 6%_ 1%a &E` 7O_ )_ 5%_ 1%a &E` 8O_ 7a 9kl :E` ;O_ ,a <ja =_ ;a >a +a ? @O_ ;j AOa B_ )a ,a C,%a D%a E_ 1%a C,%a F%_ 5_ 1%a C,%a G%a H_ 1%a C,%j IOPW X J KjE�OPO�j _ 8a ,a &E�Y a LE�Y hO�a M%_ %a N%_ %a O%_ %a P%�%E` QO_ QOPY !*�,a R  jY *�,a S  jY hOPUOPY jOP�� ��  ascr  ��ޭ