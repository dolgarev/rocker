package Settings is

   --  The duration of one main game loop cycle (in milliseconds)
   Game_Tick_Ms : constant := 50;
   
   --  The number of main loop ticks to wait before running physics logic.
   --  Physics update interval = Game_Tick_Ms * Physics_Ticks_Delay
   --  e.g., 50ms * 4 = 200ms per physics update (falling speed)
   Physics_Ticks_Delay : constant := 4;
   
   --  The duration of the death animation (in milliseconds)
   --  The sprite will blink as 'X' for this long before taking a life.
   Death_Duration_Ms : constant := 3000;
   
   --  Calculated: How many game loop ticks the player spends dead
   Death_Duration_Ticks : constant Integer := Death_Duration_Ms / Game_Tick_Ms;

end Settings;
