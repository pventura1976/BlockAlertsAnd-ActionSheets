Pod::Spec.new do |s|
  s.name         = "BlockAlertsAnd-ActionSheets"
  s.version      = "1.0.11"
  s.summary  	 = 'Beautifully done UIAlertView and UIActionSheet replacements inspired by TweetBot.'
  s.homepage     = "https://github.com/pventura1976/BlockAlertsAnd-ActionSheets"
  s.license      = 'MIT'
  s.author       = { 'Gustavo Ambrozio' => '', "Barrett Jacobsen" => "admin@barrettj.com", "Jose Santiago Jr" => '', 'Taymer Ragazzini' => 'tragazzini@gmail.com', 'Pedro Ventura' => '' }
  s.source       = { :git => 'https://github.com/pventura1976/BlockAlertsAnd-ActionSheets.git', :tag => "#{s.version}" }
  s.platform     = :ios, '4.3'
  s.source_files =  "BlockAlertsDemo/ToAddToYourProjects/BlockActionSheet.{h,m}", "BlockAlertsDemo/ToAddToYourProjects/BlockAlertView.{h,m}", "BlockAlertsDemo/ToAddToYourProjects/BlockBackground.{h,m}", "BlockAlertsDemo/ToAddToYourProjects/BlockTextPromptAlertView.{h,m}", "BlockAlertsDemo/ProjectSpecific/BlockUI.h"
  s.resources = "BlockAlertsDemo/images/button*.png", "BlockAlertsDemo/images/ActionSheet/*.png", "BlockAlertsDemo/images/AlertView/*.png"
  s.requires_arc     = false
  s.subspec 'TableAlertView' do |table|
    table.source_files = "BlockAlertsDemo/ToAddToYourProjects/BlockTableAlertView.{h,m}"
  end
  s.requires_arc = false
end

