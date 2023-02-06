package;

import states.CrashHandlerState;
import openfl.events.Event;
import haxe.CallStack;
import lime.system.System;
import sys.io.File;
import sys.FileSystem;
import openfl.events.UncaughtErrorEvent;
import flixel.FlxG;
import openfl.Lib;
import lime.app.Application;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.IntroState;

using StringTools;

class QMGame extends FlxGame
{
	override function create(_:Event)
	{
		try
		{
			super.create(_);
			FlxG.fixedTimestep = false;
		}
		catch (e)
		{
			FlxG.switchState(new CrashHandlerState(e.message, e.stack));
		}
	}

	override function draw()
	{
		try
		{
			super.draw();
		}
		catch (e)
		{
			FlxG.switchState(new CrashHandlerState(e.message, e.stack));
		}
	}

	override function update()
	{
		try
		{
			super.update();
		}
		catch (e)
		{
			trace('got a crash: ${e.message}');
			FlxG.switchState(new CrashHandlerState(e.message, e.stack));
		}
	}
}

class Main extends Sprite
{
	public function new()
	{
		super();
		// Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		var game = {
			width: 0,
			height: 0,
			initialState: IntroState,
			// Will that work?
			updateFramerate: 999,
			drawFramerate: 999,
			skipSplash: true
		};

		Preferences.loadPrefs();
		Globals.version = Lib.application.meta.get('version');

		#if desktop
		if (!QMDiscordRPC.isInitialized)
		{
			QMDiscordRPC.initialize();
			Application.current.window.onClose.add(function()
			{
				QMDiscordRPC.shutdown();
			});
		}
		#end
		addChild(new QMGame(game.width, game.height, game.initialState, game.updateFramerate, game.drawFramerate, game.skipSplash));
		addChild(new DebugCounter.FPSMem(2, 2, 0xFFFFFF));
	};

	function onCrash(e:UncaughtErrorEvent)
	{
		// QMDiscordRPC.shutdown();
		var curDate = Date.now().toString();
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		curDate = curDate.replace(" ", "_").replace(":", "'");

		if (!FileSystem.exists('./crash/'))
			FileSystem.createDirectory('./crash/');

		var errMsg:String = "Uncaught Error:\n";
		errMsg += "Call Stack that lead to this event:\n";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += '\n${e.error}\n';

		// Crash message itself
		Lib.application.window.alert(errMsg, "Uncaught Error!");
		File.saveContent('./crash/QM_$curDate.txt', errMsg);
		System.exit(1);
	}
}
