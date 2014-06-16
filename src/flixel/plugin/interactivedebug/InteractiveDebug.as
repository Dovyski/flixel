package flixel.plugin.interactivedebug
{
	import flash.display.Graphics;
	import flixel.*;
	import flixel.plugin.FlxPlugin;
	import flixel.plugin.interactivedebug.tools.Pointer;
	import flixel.ui.FlxText;
	import flixel.util.FlxPoint;
	import flixel.util.FlxU;
	
	/**
	 * A plugin to visually and interactively debug a game while it is running.
	 * 
	 * @author	Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class InteractiveDebug implements FlxPlugin
	{
		private var _toolsPanel :ToolsPanel;
		private var _selectedItems :FlxGroup;
		
		public function InteractiveDebug()
		{		
			_toolsPanel = new ToolsPanel();
			_toolsPanel.x = FlxG.debugger.overlays.width - 15;
			_toolsPanel.y = 150;
			
			FlxG.debugger.overlays.addChild(_toolsPanel);
			
			_selectedItems = new FlxGroup();
			
			addTools();
			
			// Subscrite to some Flixel signals
			FlxG.signals.postDraw.add(postDraw);
			FlxG.signals.preUpdate.add(preUpdate);
			
			//FlxG.watch(FlxG.camera.bounds, "x");
			FlxG.watch(FlxG.camera.scroll, "x");
		}
		
		private function addTools():void
		{
			_toolsPanel.addTool(new Pointer(this));
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			super.destroy();
		}
		
		/**
		 * Called before the game gets updated.
		 */
		private function preUpdate():void
		{
			_toolsPanel.update();
		}
		
		/**
		 * Called after the game state has been drawn.
		 */
		private function postDraw():void
		{
			var i:uint = 0;
			var l:uint = _selectedItems.members.length;
			var item:FlxSprite;
			
			//Set up our global flash graphics object to draw out the debug stuff
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();

			// TODO: clean up this mess, improve the code and performance.
			while (i < l)
			{
				item = _selectedItems.members[i++];
				if (item != null && item.onScreen(FlxG.camera))
				{
					gfx.lineStyle(2, 0xff0000);
					gfx.drawRect(item.x - FlxG.camera.scroll.x, item.y - FlxG.camera.scroll.y, item.width * 1.3, item.height * 1.3);
					var t:FlxText = new FlxText(item.x - FlxG.camera.scroll.x, item.y - FlxG.camera.scroll.y - 10, 200, FlxU.getClassName(item));
					t.color = 0xffff0000;
					t.scrollFactor.x = 0;
					t.scrollFactor.y = 0;
					t.draw();
				}
			}
			
			// Draw the lines to the main camera buffer
			FlxG.camera.buffer.draw(FlxG.flashGfxSprite);
		}
		
		public function get selectedItems():FlxGroup { return _selectedItems; }
	}
}
