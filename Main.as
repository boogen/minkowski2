package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
    [SWF(width="1024", height="768")]
	public class Main extends Sprite 
	{
		private var canvas:Sprite = new Sprite();
		private var origin:vec2;
		private var p1:polygon;
		private var p2:polygon;
		
		private var sticky:Boolean = false;
		private var gX:Number = 0;
		private var gY:Number = 0;
		private var dx:Number = 0;
		private var dy:Number = 0;
		private var movable:Vector.<vec2> = new Vector.<vec2>;
		private var rotable:Vector.<Object> = new Vector.<Object>;

        private var selectedEdge:Object = null;
        private var edgeColor:uint = 0;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
            edgeColor = 15602664; //Math.floor(Math.random() * 0xffffff);
			origin = new vec2(stage.stageWidth / 2, stage.stageHeight / 2);
			addChild(canvas);
			//var c1:uint = Math.floor(Math.random() * 0xffffff);
			//var c2:uint = Math.floor(Math.random() * 0xffffff);
            var c1:uint = 15947073;
            var c2:uint =  2445505;
            trace("colors:", c1, c2, edgeColor);
			
			p1 = new polygon(new matrix2x3(0, new vec2(-100, -50)), new <vec2>[ new vec2(-100, -50), new vec2(100, -50), new vec2(100, 50), new vec2(-100, 50) ], c1);
			drawpoly(p1);
			p2 = new polygon(new matrix2x3(0.01, new vec2(100, 50)), new <vec2>[ new vec2(-75, -75), new vec2(75, -75), new vec2(75, 75), new vec2(-75, 75) ], c2);
			drawpoly(p2);
			

			

			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
            selectedEdge = null;
            var v:vec2 = new vec2(e.stageX - origin.x, e.stageY - origin.y);

			if (sticky) {
			    dx = e.stageX - gX;
			    dy = e.stageY - gY;
			    gX = e.stageX;
			    gY = e.stageY;

                for (var i:int = 0; i < rotable.length; ++i) {
                    var p:polygon = rotable[i].polygon;
                    var index:int = rotable[i].index;
                    var point1:vec2 = p.matrix.rotate(p.points[index]);
                    var v1:vec2 = v.sub(p.matrix.pos);
                    var angle:Number = Math.atan2(v1.y, v1.x) - Math.atan2(point1.y, point1.x);
                    if (angle < -Math.PI) angle += 2 * Math.PI;
                    if (angle > Math.PI) angle -= 2 * Math.PI;
                    
                    p.addRotation(angle);
                }
                
			    for (var i:int = 0; i < movable.length; ++i) {

			        movable[i].x += dx;
			        movable[i].y += dy;
                    

			    }
			}
            else {

                selectEdge(v, p1);
                selectEdge(v, p2);
            }
		}

        private function selectEdge(v:vec2, p:polygon):void {
            for (var i:int = 0; i < p1.points.length; ++i) {
                var v1:vec2 = p.getGlobal(i);
                var v2:vec2 = p.getGlobal( ( i + 1) % p.points.length);
                var A:vec2 = v2.sub(v1);
                var B:vec2 = v.sub(v1);
                
                var alfa:Number = B.dot(A) / A.dot(A);
                //trace(alfa);
                if (alfa >= 0 && alfa <= 1) {
                    var C:vec2 = A.mul(alfa);
                    var dist:Number = C.sub(B).length();
                    if (dist <= 5) {
                        selectedEdge = {polygon:p, index:i};
                    }
                }
            }
            
        }
		
		private function onMouseUp(e:MouseEvent):void 
		{
			sticky = false;
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			var p:vec2 = new vec2(e.stageX - origin.x, e.stageY - origin.y);
			sticky = true;
			gX = e.stageX;
			gY = e.stageY;
            var v:vec2;
            var i:int;
			movable.length = 0;
            rotable.length = 0;
            
            for (i = 0; i < p1.points.length; ++i) {
				v = p1.getGlobal(i);
                if (v.sub(p).length() < 5) {
                    rotable.push({polygon:p1, index:i});
                }
            }

            for (i = 0; i < p2.points.length; ++i) {
				v = p2.getGlobal(i);
                if (v.sub(p).length() < 5) {
                    rotable.push({polygon:p2, index:i});
                }
            }

            if (rotable.length > 0) {
                return;
            }

			if (p1.inside(p)) {
				movable.push(p1.matrix.pos);
			}
			if (p2.inside(p)) {
				movable.push(p2.matrix.pos);
			}
			
		}
		
		private function onEnterFrame(e:Event):void 
		{
			canvas.graphics.clear();
			
			canvas.graphics.beginFill(0);
			canvas.graphics.drawCircle(origin.x, origin.y, 3);
			canvas.graphics.endFill();
			
			drawpoly(p1);
			drawpoly(p2);
			
			var minkowski:Vector.<edge> = p1.getMinkowski(p2, 1);
			for (var i:int = 0; i < minkowski.length; ++i) {
				drawEdge(minkowski[i], p1.color);
			}
            minkowski = p2.getMinkowski(p1, -1);
			for (var i:int = 0; i < minkowski.length; ++i) {
				drawEdge(minkowski[i], p2.color);
			}

            if (selectedEdge != null) {
                var p:polygon = selectedEdge.polygon;
                var index:int = selectedEdge.index;
                var gn:vec2 = p.getGlobalNormal(index);
                var pp:polygon = ( p == p1 ) ? p2 : p1;
				var sup:support = pp.getSupportVertices(gn.mul( 1))[0];
				var v1:vec2 = p.getGlobal(index).add(origin);
				var v2:vec2 = p.getGlobal( (index + 1) % p.points.length).add(origin);
                
                var sv:vec2 = sup.vec.add(origin);

                canvas.graphics.lineStyle(2, edgeColor);
                canvas.graphics.moveTo(sv.x, sv.y);
                canvas.graphics.lineTo(v1.x, v1.y);
                canvas.graphics.moveTo(sv.x, sv.y);
                canvas.graphics.lineTo(v2.x, v2.y);

                var scale:int = (p == p1) ? -1 : 1;
                var x1:Number = scale * (v1.x - sv.x) + origin.x;
                var y1:Number = scale * (v1.y - sv.y) + origin.y;
                var x2:Number = scale * (v2.x - sv.x) + origin.x;
                var y2:Number = scale * (v2.y - sv.y) + origin.y;

                canvas.graphics.moveTo(origin.x, origin.y);
                canvas.graphics.lineTo(x1, y1);
                canvas.graphics.moveTo(origin.x, origin.y);
                canvas.graphics.lineTo(x2, y2);
                
                canvas.graphics.lineStyle(1, p.color);                
                canvas.graphics.beginFill(p.color);
                canvas.graphics.drawCircle(x1, y1, 5);
                canvas.graphics.drawCircle(x2, y2, 5);
                canvas.graphics.endFill();
            }
			
			
		}
		
		public function drawpoly(p:polygon):void 
		{
			var c:uint = p.color;
			canvas.graphics.lineStyle(3, c);
			var v:vec2 = p.getGlobal(0).add(origin);
			canvas.graphics.moveTo(v.x, v.y);
			for (var i:int = 1; i <= p.points.length; ++i) {
				v = p.getGlobal(i % p.points.length).add(origin)
				canvas.graphics.lineTo(v.x, v.y);
			}

            canvas.graphics.beginFill(c);
            for (i = 0; i < p.points.length; ++i) {
				v = p.getGlobal(i % p.points.length).add(origin)
                canvas.graphics.drawCircle(v.x, v.y, 5);
            }
            canvas.graphics.endFill();
		}
		
		public function drawEdge(e:edge, c:uint):void 
		{
			canvas.graphics.lineStyle(3, c, 0.7);
			canvas.graphics.moveTo(e.v1.x + origin.x, e.v1.y + origin.y);
			canvas.graphics.lineTo(e.v2.x + origin.x, e.v2.y + origin.y);
		}
		
	}
	
}