let packageDirString = ".packages"
let generatedDirString = "generated"
let swiftWinRTId = "TheBrowserCompany.SwiftWinRT"

let projectionText = #"""
# Dependencies

- id: TheBrowserCompany.SwiftWinRT
  version: 0.5.0
- id: Microsoft.Windows.SDK.Contracts
  version: 10.0.18362.2005
- id: Microsoft.WindowsAppSDK
  version: 1.5.240205001-preview1
- id: Microsoft.Graphics.Win2D
  version: 1.1.1

# Modules

Include if checkbox fill in "I"
Exclude if checkbox fill in "E"

## from https://github.com/thebrowsercompany/swift-cwinrt

- [I] Microsoft.UI.ColorHelper
- [I] Microsoft.UI.Colors
- [I] Microsoft.UI.Xaml.Application
- [I] Microsoft.UI.Xaml.Automation.AutomationProperties
- [I] Microsoft.UI.Xaml.Controls.BitmapIcon
- [I] Microsoft.UI.Xaml.Controls.Border
- [I] Microsoft.UI.Xaml.Controls.Button
- [I] Microsoft.UI.Xaml.Controls.Canvas
- [I] Microsoft.UI.Xaml.Controls.CheckBox
- [I] Microsoft.UI.Xaml.Controls.ColumnDefinition
- [I] Microsoft.UI.Xaml.Controls.ComboBox
- [I] Microsoft.UI.Xaml.Controls.ContentDialog
- [I] Microsoft.UI.Xaml.Controls.ContentPresenter
- [I] Microsoft.UI.Xaml.Controls.FlipView
- [I] Microsoft.UI.Xaml.Controls.FlipViewItem
- [I] Microsoft.UI.Xaml.Controls.Flyout
- [I] Microsoft.UI.Xaml.Controls.FlyoutPresenter
- [I] Microsoft.UI.Xaml.Controls.FontIcon
- [I] Microsoft.UI.Xaml.Controls.FontIconSource
- [I] Microsoft.UI.Xaml.Controls.Grid
- [I] Microsoft.UI.Xaml.Controls.GridView
- [I] Microsoft.UI.Xaml.Controls.IconSourceElement
- [I] Microsoft.UI.Xaml.Controls.IKeyIndexMapping
- [I] Microsoft.UI.Xaml.Controls.Image
- [I] Microsoft.UI.Xaml.Controls.ImageIcon
- [I] Microsoft.UI.Xaml.Controls.InfoBar
- [I] Microsoft.UI.Xaml.Controls.ItemsRepeater
- [I] Microsoft.UI.Xaml.Controls.HyperlinkButton
- [I] Microsoft.UI.Xaml.Controls.ListBox
- [I] Microsoft.UI.Xaml.Controls.ListBoxItem
- [I] Microsoft.UI.Xaml.Controls.MediaPlayerElement
- [I] Microsoft.UI.Xaml.Controls.MenuBar
- [I] Microsoft.UI.Xaml.Controls.MenuBarItem
- [I] Microsoft.UI.Xaml.Controls.MenuFlyout
- [I] Microsoft.UI.Xaml.Controls.MenuFlyoutItem
- [I] Microsoft.UI.Xaml.Controls.MenuFlyoutSeparator
- [I] Microsoft.UI.Xaml.Controls.MenuFlyoutSubItem
- [I] Microsoft.UI.Xaml.Controls.ToggleMenuFlyoutItem
- [I] Microsoft.UI.Xaml.Controls.Page
- [I] Microsoft.UI.Xaml.Controls.PasswordBox
- [I] Microsoft.UI.Xaml.Controls.PipsPager
- [I] Microsoft.UI.Xaml.Controls.ProgressBar
- [I] Microsoft.UI.Xaml.Controls.ProgressRing
- [I] Microsoft.UI.Xaml.Controls.RadioButton
- [I] Microsoft.UI.Xaml.Controls.RadioButtons
- [I] Microsoft.UI.Xaml.Controls.RelativePanel
- [I] Microsoft.UI.Xaml.Controls.RowDefinition
- [I] Microsoft.UI.Xaml.Controls.Slider
- [I] Microsoft.UI.Xaml.Controls.ScrollView
- [I] Microsoft.UI.Xaml.Controls.SplitView
- [I] Microsoft.UI.Xaml.Controls.StackLayout
- [I] Microsoft.UI.Xaml.Controls.StackPanel
- [I] Microsoft.UI.Xaml.Controls.SwapChainPanel
- [I] Microsoft.UI.Xaml.Controls.TeachingTip
- [I] Microsoft.UI.Xaml.Controls.ToolTip
- [I] Microsoft.UI.Xaml.Controls.ToolTipService
- [I] Microsoft.UI.Xaml.Controls.TextBlock
- [I] Microsoft.UI.Xaml.Controls.TextBox
- [I] Microsoft.UI.Xaml.Controls.ToggleSwitch
- [I] Microsoft.UI.Xaml.Controls.TreeView
- [I] Microsoft.UI.Xaml.Controls.TreeViewItem
- [I] Microsoft.UI.Xaml.Controls.TreeViewList
- [I] Microsoft.UI.Xaml.Controls.UniformGridLayout
- [I] Microsoft.UI.Xaml.Controls.XamlControlsResources
- [I] Microsoft.UI.Xaml.Documents.Run
- [I] Microsoft.UI.Xaml.Documents.Hyperlink
- [I] Microsoft.UI.Xaml.Hosting.DesktopWindowXamlSource
- [I] Microsoft.UI.Xaml.Hosting.ElementCompositionPreview
- [I] Microsoft.UI.Xaml.Hosting.WindowsXamlManager
- [I] Microsoft.UI.Xaml.Input.FocusManager
- [I] Microsoft.UI.Xaml.Interop.INotifyCollectionChanged
- [I] Microsoft.UI.Xaml.Markup.IComponentConnector
- [I] Microsoft.UI.Xaml.Markup.IDataTemplateComponent
- [I] Microsoft.UI.Xaml.Markup.XamlBindingHelper
- [I] Microsoft.UI.Xaml.Markup.XamlReader
- [I] Microsoft.UI.Xaml.Media.Animation
- [I] Microsoft.UI.Xaml.Media.AcrylicBrush
- [I] Microsoft.UI.Xaml.Media.CompositeTransform
- [I] Microsoft.UI.Xaml.Media.CompositionTarget
- [I] Microsoft.UI.Xaml.Media.GradientStop
- [I] Microsoft.UI.Xaml.Media.GradientStopCollection
- [I] Microsoft.UI.Xaml.Media.Imaging
- [I] Microsoft.UI.Xaml.Media.LinearGradientBrush
- [I] Microsoft.UI.Xaml.Media.LineSegment
- [I] Microsoft.UI.Xaml.Media.MicaBackdrop
- [I] Microsoft.UI.Xaml.Media.PathGeometry
- [I] Microsoft.UI.Xaml.Media.PolyBezierSegment
- [I] Microsoft.UI.Xaml.Media.ThemeShadow
- [I] Microsoft.UI.Xaml.Media.Transform
- [I] Microsoft.UI.Xaml.Media.TranslateTransform
- [I] Microsoft.UI.Xaml.Media.VisualTreeHelper
- [I] Microsoft.UI.Xaml.Setter
- [I] Microsoft.UI.Xaml.Shapes.Ellipse
- [I] Microsoft.UI.Xaml.Shapes.Path
- [I] Microsoft.UI.Xaml.Shapes.Rectangle
- [I] Microsoft.UI.Xaml.Window
- [I] Microsoft.UI.Xaml.XamlTypeInfo.XamlControlsXamlMetaDataProvider

## from https://github.com/thebrowsercompany/swift-windowsfoundation

- [I] Windows.Foundation.Collections
- [I] Windows.Foundation.Numerics
- [I] Windows.Foundation
- [E] Windows.Foundation.PropertyValue

## from https://github.com/thebrowsercompany/swift-windowsappsdk

- [I] Microsoft.UI.Composition
- [I] Microsoft.UI.Composition.Interactions
- [I] Microsoft.UI.Composition.SpringVector3NaturalMotionAnimation
- [I] Microsoft.UI.Composition.SystemBackdrops
- [I] Microsoft.UI.Content.DesktopChildSiteBridge
- [I] Microsoft.UI.Dispatching.DispatcherQueueController
- [I] Microsoft.UI.Input
- [I] Microsoft.UI.Windowing.AppWindow
- [I] Microsoft.UI.Windowing.AppWindowTitleBar
- [I] Microsoft.UI.Windowing.DisplayArea
- [I] Microsoft.UI.Windowing.FullScreenPresenter
- [I] Microsoft.UI.Windowing.OverlappedPresenter
- [I] Microsoft.Windows.ApplicationModel.Resources.ResourceManager
- [I] Microsoft.Windows.AppLifecycle.ActivationRegistrationManager
- [I] Microsoft.Windows.AppLifecycle.AppInstance

## from https://github.com/thebrowsercompany/swift-uwp

- [I] Windows.ApplicationModel.Activation.LaunchActivatedEventArgs
- [I] Windows.ApplicationModel.Core
- [I] Windows.ApplicationModel.DataTransfer
- [I] Windows.ApplicationModel.DataTransfer.DragDrop
- [I] Windows.Management.Deployment.PackageManager
- [I] Windows.ApplicationModel.Activation.ProtocolActivatedEventArgs
- [I] Windows.Devices.Input
- [I] Windows.Foundation.IMemoryBufferReference
- [I] Windows.Foundation.IPropertyValue
- [I] Windows.Graphics
- [I] Windows.Graphics.DirectX.Direct3D11
- [I] Windows.Graphics.Effects
- [I] Windows.Graphics.Imaging
- [I] Windows.Media.Audio
- [I] Windows.Media.Casting
- [I] Windows.Media.Core.MediaSource
- [I] Windows.Media.Render
- [I] Windows.Media.Playback.MediaPlayer
- [I] Windows.Storage.Streams
- [I] Windows.Storage.Pickers
- [I] Windows.System.Launcher
- [I] Windows.System.Diagnostics.SystemDiagnosticInfo
- [I] Windows.System.VirtualKeyModifiers
- [I] Windows.UI.Color
- [I] Windows.UI.Composition
- [I] Windows.UI.Core.CoreCursor
- [I] Windows.UI.Core.CoreWindow
- [I] Windows.UI.Notifications
- [I] Windows.UI.Text.TextDecorations
- [I] Windows.UI.Text.FontWeights
- [I] Windows.UI.Text.FontStyle
- [I] Windows.UI.Text.FontStretch
- [I] Windows.UI.ViewManagement.UISettings
- [E] Windows.Devices.Enumeration.Panel
- [E] Windows.Management.Deployment.PackageStatus
- [E] Windows.ApplicationModel.Core.CoreApplication

## from https://github.com/thebrowsercompany/swift-winui

- [I] Microsoft.UI.ColorHelper
- [I] Microsoft.UI.Colors
- [I] Microsoft.UI.Xaml.Application
- [I] Microsoft.UI.Xaml.Automation.AutomationProperties
- [I] Microsoft.UI.Xaml.Controls.BitmapIcon
- [I] Microsoft.UI.Xaml.Controls.Border
- [I] Microsoft.UI.Xaml.Controls.Button
- [I] Microsoft.UI.Xaml.Controls.Canvas
- [I] Microsoft.UI.Xaml.Controls.CheckBox
- [I] Microsoft.UI.Xaml.Controls.ColumnDefinition
- [I] Microsoft.UI.Xaml.Controls.ComboBox
- [I] Microsoft.UI.Xaml.Controls.ContentDialog
- [I] Microsoft.UI.Xaml.Controls.ContentPresenter
- [I] Microsoft.UI.Xaml.Controls.FlipView
- [I] Microsoft.UI.Xaml.Controls.FlipViewItem
- [I] Microsoft.UI.Xaml.Controls.Flyout
- [I] Microsoft.UI.Xaml.Controls.FlyoutPresenter
- [I] Microsoft.UI.Xaml.Controls.FontIcon
- [I] Microsoft.UI.Xaml.Controls.FontIconSource
- [I] Microsoft.UI.Xaml.Controls.Grid
- [I] Microsoft.UI.Xaml.Controls.GridView
- [I] Microsoft.UI.Xaml.Controls.IconSourceElement
- [I] Microsoft.UI.Xaml.Controls.IKeyIndexMapping
- [I] Microsoft.UI.Xaml.Controls.Image
- [I] Microsoft.UI.Xaml.Controls.ImageIcon
- [I] Microsoft.UI.Xaml.Controls.InfoBar
- [I] Microsoft.UI.Xaml.Controls.ItemsRepeater
- [I] Microsoft.UI.Xaml.Controls.HyperlinkButton
- [I] Microsoft.UI.Xaml.Controls.ListBox
- [I] Microsoft.UI.Xaml.Controls.ListBoxItem
- [I] Microsoft.UI.Xaml.Controls.MediaPlayerElement
- [I] Microsoft.UI.Xaml.Controls.MenuBar
- [I] Microsoft.UI.Xaml.Controls.MenuBarItem
- [I] Microsoft.UI.Xaml.Controls.MenuFlyout
- [I] Microsoft.UI.Xaml.Controls.MenuFlyoutItem
- [I] Microsoft.UI.Xaml.Controls.MenuFlyoutSeparator
- [I] Microsoft.UI.Xaml.Controls.MenuFlyoutSubItem
- [I] Microsoft.UI.Xaml.Controls.ToggleMenuFlyoutItem
- [I] Microsoft.UI.Xaml.Controls.Page
- [I] Microsoft.UI.Xaml.Controls.PasswordBox
- [I] Microsoft.UI.Xaml.Controls.PipsPager
- [I] Microsoft.UI.Xaml.Controls.ProgressBar
- [I] Microsoft.UI.Xaml.Controls.ProgressRing
- [I] Microsoft.UI.Xaml.Controls.RadioButton
- [I] Microsoft.UI.Xaml.Controls.RadioButtons
- [I] Microsoft.UI.Xaml.Controls.RelativePanel
- [I] Microsoft.UI.Xaml.Controls.RowDefinition
- [I] Microsoft.UI.Xaml.Controls.Slider
- [I] Microsoft.UI.Xaml.Controls.ScrollView
- [I] Microsoft.UI.Xaml.Controls.SplitView
- [I] Microsoft.UI.Xaml.Controls.StackLayout
- [I] Microsoft.UI.Xaml.Controls.StackPanel
- [I] Microsoft.UI.Xaml.Controls.SwapChainPanel
- [I] Microsoft.UI.Xaml.Controls.TeachingTip
- [I] Microsoft.UI.Xaml.Controls.ToolTip
- [I] Microsoft.UI.Xaml.Controls.ToolTipService
- [I] Microsoft.UI.Xaml.Controls.TextBlock
- [I] Microsoft.UI.Xaml.Controls.TextBox
- [I] Microsoft.UI.Xaml.Controls.ToggleSwitch
- [I] Microsoft.UI.Xaml.Controls.TreeView
- [I] Microsoft.UI.Xaml.Controls.TreeViewItem
- [I] Microsoft.UI.Xaml.Controls.TreeViewList
- [I] Microsoft.UI.Xaml.Controls.UniformGridLayout
- [I] Microsoft.UI.Xaml.Controls.XamlControlsResources
- [I] Microsoft.UI.Xaml.Documents.Run
- [I] Microsoft.UI.Xaml.Documents.Hyperlink
- [I] Microsoft.UI.Xaml.Hosting.DesktopWindowXamlSource
- [I] Microsoft.UI.Xaml.Hosting.ElementCompositionPreview
- [I] Microsoft.UI.Xaml.Hosting.WindowsXamlManager
- [I] Microsoft.UI.Xaml.Input.FocusManager
- [I] Microsoft.UI.Xaml.Interop.INotifyCollectionChanged
- [I] Microsoft.UI.Xaml.Markup.IComponentConnector
- [I] Microsoft.UI.Xaml.Markup.IDataTemplateComponent
- [I] Microsoft.UI.Xaml.Markup.XamlBindingHelper
- [I] Microsoft.UI.Xaml.Markup.XamlReader
- [I] Microsoft.UI.Xaml.Media.Animation
- [I] Microsoft.UI.Xaml.Media.AcrylicBrush
- [I] Microsoft.UI.Xaml.Media.CompositeTransform
- [I] Microsoft.UI.Xaml.Media.CompositionTarget
- [I] Microsoft.UI.Xaml.Media.GradientStop
- [I] Microsoft.UI.Xaml.Media.GradientStopCollection
- [I] Microsoft.UI.Xaml.Media.Imaging
- [I] Microsoft.UI.Xaml.Media.LinearGradientBrush
- [I] Microsoft.UI.Xaml.Media.LineSegment
- [I] Microsoft.UI.Xaml.Media.MicaBackdrop
- [I] Microsoft.UI.Xaml.Media.PathGeometry
- [I] Microsoft.UI.Xaml.Media.PolyBezierSegment
- [I] Microsoft.UI.Xaml.Media.ThemeShadow
- [I] Microsoft.UI.Xaml.Media.Transform
- [I] Microsoft.UI.Xaml.Media.TranslateTransform
- [I] Microsoft.UI.Xaml.Media.VisualTreeHelper
- [I] Microsoft.UI.Xaml.Setter
- [I] Microsoft.UI.Xaml.Shapes.Ellipse
- [I] Microsoft.UI.Xaml.Shapes.Path
- [I] Microsoft.UI.Xaml.Shapes.Rectangle
- [I] Microsoft.UI.Xaml.Window
- [I] Microsoft.UI.Xaml.XamlTypeInfo.XamlControlsXamlMetaDataProvider

## from https://github.com/thebrowsercompany/swift-win2d

- [I] Microsoft.Graphics.Canvas
- [I] Microsoft.Graphics.Canvas.UI.Xaml

"""#
