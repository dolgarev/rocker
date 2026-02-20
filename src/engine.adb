package body Engine is

   procedure Initialize (State : out Game_State) is
   begin
      State.Map := [others => [others => Space]];
      State.Player_Row := 1;
      State.Player_Col := 1;
      State.Diamonds_Needed := 0;
      State.Diamonds_Held := 0;
      State.Score := 0;
      State.Lives := 3;
      State.Tick_Count := 0;
      State.Game_Over := False;
      State.Level_Complete := False;
   end Initialize;

   procedure Move_Player (State : in out Game_State; DR, DC : Integer) is
      New_R : constant Integer := State.Player_Row + DR;
      New_C : constant Integer := State.Player_Col + DC;
   begin
      if New_R not in 1 .. Max_Rows or New_C not in 1 .. Max_Cols then
         return;
      end if;

      case State.Map (New_R, New_C) is
         when Space | Dirt =>
            State.Map (State.Player_Row, State.Player_Col) := Space;
            State.Player_Row := New_R;
            State.Player_Col := New_C;
            State.Map (New_R, New_C) := Player;
            
         when Diamond | Falling_Diamond =>
            State.Map (State.Player_Row, State.Player_Col) := Space;
            State.Player_Row := New_R;
            State.Player_Col := New_C;
            State.Map (New_R, New_C) := Player;
            State.Diamonds_Held := State.Diamonds_Held + 1;
            State.Score := State.Score + 10;
            
            if State.Diamonds_Held >= State.Diamonds_Needed then
               for R in 1 .. Max_Rows loop
                  for C in 1 .. Max_Cols loop
                     if State.Map (R, C) = Exit_Closed then
                        State.Map (R, C) := Exit_Open;
                     end if;
                  end loop;
               end loop;
            end if;
            
         when Boulder =>
            -- Push boulder mechanic (only horizontal)
            if DR = 0 and then New_C + DC in 1 .. Max_Cols 
               and then State.Map (New_R, New_C + DC) = Space 
            then
               State.Map (New_R, New_C + DC) := Boulder;
               State.Map (New_R, New_C) := Player;
               State.Map (State.Player_Row, State.Player_Col) := Space;
               State.Player_Row := New_R;
               State.Player_Col := New_C;
            end if;

         when Falling_Boulder =>
            null; -- Blocked when moving into a falling rock

         when Exit_Open =>
            State.Level_Complete := True;

         when others =>
            null;
      end case;
   end Move_Player;

   procedure Update_Physics (State : in out Game_State) is
      Current : Entity_Type;
      Next    : Entity_Type;
      
      function To_Stationary (E : Entity_Type) return Entity_Type is
      begin
         if E = Falling_Boulder then return Boulder; end if;
         if E = Falling_Diamond then return Diamond; end if;
         return E;
      end To_Stationary;

      function To_Falling (E : Entity_Type) return Entity_Type is
      begin
         if E = Boulder then return Falling_Boulder; end if;
         if E = Diamond then return Falling_Diamond; end if;
         return E;
      end To_Falling;

   begin
      State.Tick_Count := State.Tick_Count + 1;
      -- SLOW DOWN: Only run physics every X ticks. 
      -- Loop is 100ms, mod 688 = physics every 68.8s.
      -- Delay before move = Activation (68.8s) + Movement (68.8s) = 137.6s total.
      if State.Tick_Count mod 688 /= 0 then
         return;
      end if;

      -- Iterate from bottom to top to avoid double-processing in one tick
      for R in reverse 1 .. Max_Rows - 1 loop
         for C in 1 .. Max_Cols loop
            Current := State.Map (R, C);
            
            if Current = Boulder or Current = Diamond or 
               Current = Falling_Boulder or Current = Falling_Diamond 
            then
               Next := State.Map (R + 1, C);

               -- 1. Try falling straight down
               if Next = Space then
                  if Current = Boulder or Current = Diamond then
                     -- ACTIVATION: State changes but object stays for 1 tick
                     State.Map (R, C) := To_Falling (Current);
                  else
                     -- MOVEMENT: Move the object
                     State.Map (R + 1, C) := Current;
                     State.Map (R, C) := Space;
                  end if;
                  
               -- 2. Crush logic (only if ALREADY falling)
               elsif Next = Player then
                  if Current = Falling_Boulder or Current = Falling_Diamond then
                     State.Lives := State.Lives - 1;
                     State.Map (R + 1, C) := To_Stationary (Current);
                     State.Map (R, C) := Space;
                     
                     -- Reset player pos (clear old)
                     State.Map (State.Player_Row, State.Player_Col) := Space;
                     State.Player_Row := 2;
                     State.Player_Col := 2;
                     State.Map (2, 2) := Player;
                     
                     if State.Lives <= 0 then
                        State.Game_Over := True;
                     end if;
                  end if;
               
               -- 3. Slide logic (Rounded surfaces)
               elsif Next = Boulder or Next = Diamond or Next = Wall then
                  -- Slide left
                  if C > 1 and then State.Map (R, C - 1) = Space and then State.Map (R + 1, C - 1) = Space then
                     State.Map (R, C - 1) := To_Falling (Current);
                     State.Map (R, C) := Space;
                  -- Slide right
                  elsif C < Max_Cols and then State.Map (R, C + 1) = Space and then State.Map (R + 1, C + 1) = Space then
                     State.Map (R, C + 1) := To_Falling (Current);
                     State.Map (R, C) := Space;
                  else
                     State.Map (R, C) := To_Stationary (Current);
                  end if;
                  
               -- 4. Blocked
               else
                  State.Map (R, C) := To_Stationary (Current);
               end if;
            end if;
         end loop;
      end loop;
   end Update_Physics;

end Engine;
