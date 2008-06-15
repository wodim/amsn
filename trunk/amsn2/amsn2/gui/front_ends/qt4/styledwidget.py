import sys

try:
    from PyQt4.QtCore import *
    from PyQt4.QtGui import *
    from ui_login import Ui_Login
    from fadingwidget import FadingWidget
except ImportError, msg:
    print "Could not import all required modules for the Qt 4 GUI."
    print "ImportError: " + str(msg)
    sys.exit()

# Styled Widget: QWidget subclass that directly supports Qt StyleSheets
class StyledWidget(QWidget):
    def __init__(self, parent=None):
        QWidget.__init__(self, parent)

    # Needed to support StyleSheets on pure subclassed QWidgets
    # See: http://doc.trolltech.com/4.4/stylesheet-reference.html
    def paintEvent(self, event):
        opt = QStyleOption()
        opt.init(self)
        p = QPainter(self)
        self.style().drawPrimitive(QStyle.PE_Widget, opt, p, self)