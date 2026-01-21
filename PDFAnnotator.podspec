Pod::Spec.new do |s|
  s.name             = 'PDFAnnotator'
  s.version          = '1.0.2'
  s.summary          = 'A tool to download, view, and annotate PDFs.'
  s.description      = 'This pod handles remote PDF downloading and allows drawing annotations directly on the document.'
  s.homepage         = 'https://github.com/vyshnav-meridian/PDFAnnotator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vyshnav-meridian' => 'vyshnav@meridian.net.in' }
  s.source           = { :git => 'https://github.com/vyshnav-meridian/PDFAnnotator.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version    = '5.0'

  # This maps your SPM structure to CocoaPods
  s.source_files     = 'Sources/PDFAnnotator/**/*'
  
  s.frameworks       = 'UIKit', 'PDFKit'
end
