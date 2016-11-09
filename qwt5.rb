class Qwt5 < Formula
  desc "Qt Widgets for Technical Applications"
  homepage "http://qwt.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/qwt/qwt/5.2.1/qwt-5.2.1.tar.bz2"
  sha256 "e2b8bb755404cb3dc99e61f3e2d7262152193488f5fbe88524eb698e11ac569f"
  # url "https://downloads.sourceforge.net/project/qwt/qwt/5.2.3/qwt-5.2.3.tar.bz2"
  # sha256 "37feaf306753230b0d8538b4ff9b255c6fddaa3d6609ec5a5cc39a5a4d020ab7"

  option "with-qwtmathml", "Build the qwtmathml library"
  option "without-plugin", "Skip building the Qt Designer plugin"

  depends_on "qt"

  def install
    inreplace "qwtconfig.pri" do |s|
      s.gsub! /^\s*INSTALLBASE\s*=(.*)$/, "INSTALLBASE=#{prefix}"
      s.sub! /\+(=\s*QwtDesigner)/, "-\\1" if build.without? "plugin"
    end

    args = ["-config", "release", "-spec", "macx-g++"]

    if build.with? "qwtmathml"
      args << "QWT_CONFIG+=QwtMathML"
      prefix.install "textengines/mathml/qtmmlwidget-license"
    end

    system Formula["qt"].bin/"qmake", *args
    system "make"
    system "make", "install"
  end

  def caveats
    s = ""

    if build.with? "qwtmathml"
      s += <<-EOS.undent
        The qwtmathml library contains code of the MML Widget from the Qt solutions package.
        Beside the Qwt license you also have to take care of its license:
        #{opt_prefix}/qtmmlwidget-license
      EOS
    end

    s
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <qwt_plot_curve.h>
      int main() {
        QwtPlotCurve *curve1 = new QwtPlotCurve("Curve 1");
        return (curve1 == NULL);
      }
    EOS
    system ENV.cxx, "test.cpp", "-o", "out",
      "-std=c++11",
      "-framework", "qwt", "-framework", "QtCore",
      "-F#{lib}", "-F#{Formula["qt"].opt_lib}",
      "-I#{lib}/qwt.framework/Headers",
      "-I#{Formula["qt"].opt_lib}/QtCore.framework/Versions/4/Headers",
      "-I#{Formula["qt"].opt_lib}/QtGui.framework/Versions/4/Headers"
    system "./out"
  end
end
