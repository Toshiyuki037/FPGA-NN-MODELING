"""
Day started: July 12, 2026
Last edited: July 12, 2026
Name: Max Maehara
Code purpose:
    Prototype Layer 1 of the evolutionary FPGA agent system.

    This program contains:
    1. A simple 2D-grid simulator.
    2. Six observation values from the simulator.
    3. A 6-8-12-4 neural network.
    4. Four possible movement actions.
    5. A 200-step simulation loop.
    6. Genome functions for the future genetic algorithm.

Important:
    This network does not learn yet.
    Its weights are initially random.

    Later, Layer 2 will evolve the network's 216 parameters.
"""

import math
import random
from typing import List


# ============================================================
# ACTIVATION FUNCTION
# ============================================================

def tanh(value: float) -> float:
    """
    Squashes any number into the range -1 to +1.

    Examples:
        tanh(100)  -> approximately 1
        tanh(0)    -> 0
        tanh(-100) -> approximately -1
    """
    return math.tanh(value)


# ============================================================
# DENSE NEURAL-NETWORK LAYER
# ============================================================

class DenseLayer:
    """
    A fully connected neural-network layer.

    Every output neuron receives every input value.

    For one neuron:

        result =
            input_1 * weight_1
          + input_2 * weight_2
          + ...
          + bias

    The activation function is applied afterward.
    """

    def __init__(
        self,
        number_of_inputs: int,
        number_of_outputs: int,
        use_activation: bool = True,
    ) -> None:

        self.number_of_inputs = number_of_inputs
        self.number_of_outputs = number_of_outputs
        self.use_activation = use_activation

        # weights[output_neuron][input_connection]
        #
        # Example for a 6 -> 8 layer:
        # There are 8 rows.
        # Each row contains 6 weights.
        self.weights: List[List[float]] = []

        for _ in range(number_of_outputs):
            neuron_weights = []

            for _ in range(number_of_inputs):
                random_weight = random.uniform(-1.0, 1.0)
                neuron_weights.append(random_weight)

            self.weights.append(neuron_weights)

        # Every output neuron has one bias.
        self.biases: List[float] = [
            random.uniform(-1.0, 1.0)
            for _ in range(number_of_outputs)
        ]

    def forward(self, inputs: List[float]) -> List[float]:
        """
        Pass input values through this layer.

        Returns one value for each output neuron.
        """

        if len(inputs) != self.number_of_inputs:
            raise ValueError(
                f"Layer expected {self.number_of_inputs} inputs, "
                f"but received {len(inputs)}."
            )

        outputs: List[float] = []

        # Calculate one output neuron at a time.
        for neuron_index in range(self.number_of_outputs):

            # Start with this neuron's bias.
            neuron_total = self.biases[neuron_index]

            # Multiply each input by its weight and add the results.
            for input_index in range(self.number_of_inputs):
                input_value = inputs[input_index]
                weight = self.weights[neuron_index][input_index]

                neuron_total += input_value * weight

            # Hidden layers use tanh.
            if self.use_activation:
                neuron_total = tanh(neuron_total)

            outputs.append(neuron_total)

        return outputs

    def get_parameters(self) -> List[float]:
        """
        Return all weights and biases as one flat list.

        The genetic algorithm will treat this list as the genome.
        """

        parameters: List[float] = []

        for neuron_weights in self.weights:
            parameters.extend(neuron_weights)

        parameters.extend(self.biases)

        return parameters

    def set_parameters(self, parameters: List[float]) -> None:
        """
        Replace this layer's weights and biases.

        Layer 2 will eventually use this function when it creates
        mutated or crossed-over agents.
        """

        expected_count = (
            self.number_of_inputs * self.number_of_outputs
            + self.number_of_outputs
        )

        if len(parameters) != expected_count:
            raise ValueError(
                f"Expected {expected_count} parameters, "
                f"but received {len(parameters)}."
            )

        parameter_index = 0

        for output_index in range(self.number_of_outputs):
            for input_index in range(self.number_of_inputs):
                self.weights[output_index][input_index] = (
                    parameters[parameter_index]
                )
                parameter_index += 1

        for output_index in range(self.number_of_outputs):
            self.biases[output_index] = parameters[parameter_index]
            parameter_index += 1


# ============================================================
# COMPLETE 6-8-12-4 AGENT NETWORK
# ============================================================

class AgentNetwork:
    """
    The complete Layer-1 agent brain.

        6 observations
              ↓
        8 hidden neurons
              ↓
        12 hidden neurons
              ↓
        4 action outputs
    """

    def __init__(self) -> None:

        # Six simulator observations become eight values.
        self.layer_1 = DenseLayer(
            number_of_inputs=6,
            number_of_outputs=8,
            use_activation=True,
        )

        # The eight values become twelve values.
        self.layer_2 = DenseLayer(
            number_of_inputs=8,
            number_of_outputs=12,
            use_activation=True,
        )

        # The twelve values become four action scores.
        #
        # The final layer does not need tanh because we only care
        # about which output has the largest value.
        self.output_layer = DenseLayer(
            number_of_inputs=12,
            number_of_outputs=4,
            use_activation=False,
        )

    def forward(self, observations: List[float]) -> List[float]:
        """
        Send six observation values through the complete network.
        """

        hidden_1 = self.layer_1.forward(observations)
        hidden_2 = self.layer_2.forward(hidden_1)
        action_scores = self.output_layer.forward(hidden_2)

        return action_scores

    def choose_action(self, observations: List[float]) -> int:
        """
        Choose the action with the largest output score.

        Action numbers:
            0 = move up
            1 = move down
            2 = move left
            3 = move right
        """

        action_scores = self.forward(observations)

        best_action = max(
            range(len(action_scores)),
            key=lambda index: action_scores[index],
        )

        return best_action

    def get_genome(self) -> List[float]:
        """
        Return all 216 neural-network parameters.

        This is the agent's genome.
        """

        genome: List[float] = []

        genome.extend(self.layer_1.get_parameters())
        genome.extend(self.layer_2.get_parameters())
        genome.extend(self.output_layer.get_parameters())

        return genome

    def set_genome(self, genome: List[float]) -> None:
        """
        Load a complete 216-parameter genome into the network.
        """

        if len(genome) != 216:
            raise ValueError(
                f"A 6-8-12-4 network requires 216 parameters, "
                f"but received {len(genome)}."
            )

        layer_1_count = 6 * 8 + 8       # 56
        layer_2_count = 8 * 12 + 12     # 108
        output_count = 12 * 4 + 4       # 52

        start = 0
        end = layer_1_count

        self.layer_1.set_parameters(genome[start:end])

        start = end
        end += layer_2_count

        self.layer_2.set_parameters(genome[start:end])

        start = end
        end += output_count

        self.output_layer.set_parameters(genome[start:end])


# ============================================================
# BASIC 2D-GRID SIMULATOR
# ============================================================

class GridWorld:
    """
    A small simulator used to test the Layer-1 neural network.

    The agent tries to move toward a target.

    A real simulator can replace this class later without changing
    the neural-network architecture.
    """

    def __init__(self, width: int = 10, height: int = 10) -> None:

        if width < 2 or height < 2:
            raise ValueError("Grid width and height must be at least 2.")

        self.width = width
        self.height = height

        self.agent_x = 0
        self.agent_y = 0

        self.target_x = 0
        self.target_y = 0

        self.collisions = 0
        self.targets_reached = 0
        self.total_distance_moved = 0

        self.reset()

    def reset(self) -> None:
        """
        Place the agent and target at random locations.
        """

        self.agent_x = random.randrange(self.width)
        self.agent_y = random.randrange(self.height)

        self.target_x = random.randrange(self.width)
        self.target_y = random.randrange(self.height)

        # Prevent the target from starting on the agent.
        while (
            self.target_x == self.agent_x
            and self.target_y == self.agent_y
        ):
            self.target_x = random.randrange(self.width)
            self.target_y = random.randrange(self.height)

        self.collisions = 0
        self.targets_reached = 0
        self.total_distance_moved = 0

    def get_observations(self) -> List[float]:
        """
        Produce exactly six normalized simulator values.

        Observation 0: distance to upper wall
        Observation 1: distance to lower wall
        Observation 2: distance to left wall
        Observation 3: distance to right wall
        Observation 4: horizontal target direction
        Observation 5: vertical target direction
        """

        distance_up = self.agent_y / (self.height - 1)

        distance_down = (
            self.height - 1 - self.agent_y
        ) / (self.height - 1)

        distance_left = self.agent_x / (self.width - 1)

        distance_right = (
            self.width - 1 - self.agent_x
        ) / (self.width - 1)

        target_horizontal = (
            self.target_x - self.agent_x
        ) / (self.width - 1)

        target_vertical = (
            self.target_y - self.agent_y
        ) / (self.height - 1)

        return [
            distance_up,
            distance_down,
            distance_left,
            distance_right,
            target_horizontal,
            target_vertical,
        ]

    def take_action(self, action: int) -> None:
        """
        Apply one of the network's four actions.

        Coordinate system:

            y decreases when moving up
            y increases when moving down
            x decreases when moving left
            x increases when moving right
        """

        old_x = self.agent_x
        old_y = self.agent_y

        if action == 0:
            new_x = self.agent_x
            new_y = self.agent_y - 1

        elif action == 1:
            new_x = self.agent_x
            new_y = self.agent_y + 1

        elif action == 2:
            new_x = self.agent_x - 1
            new_y = self.agent_y

        elif action == 3:
            new_x = self.agent_x + 1
            new_y = self.agent_y

        else:
            raise ValueError(f"Invalid action: {action}")

        # Stop the agent from leaving the simulator.
        if (
            new_x < 0
            or new_x >= self.width
            or new_y < 0
            or new_y >= self.height
        ):
            self.collisions += 1
            return

        self.agent_x = new_x
        self.agent_y = new_y

        if old_x != self.agent_x or old_y != self.agent_y:
            self.total_distance_moved += 1

        # Check whether the agent reached the target.
        if (
            self.agent_x == self.target_x
            and self.agent_y == self.target_y
        ):
            self.targets_reached += 1

            # Generate a new target.
            self.target_x = random.randrange(self.width)
            self.target_y = random.randrange(self.height)

            while (
                self.target_x == self.agent_x
                and self.target_y == self.agent_y
            ):
                self.target_x = random.randrange(self.width)
                self.target_y = random.randrange(self.height)

    def distance_to_target(self) -> int:
        """
        Calculate Manhattan distance to the target.
        """

        return (
            abs(self.target_x - self.agent_x)
            + abs(self.target_y - self.agent_y)
        )


# ============================================================
# RUN ONE AGENT FOR 200 STEPS
# ============================================================

def run_agent(number_of_steps: int = 200) -> None:
    """
    Create one random neural-network agent and test it.
    """

    simulator = GridWorld(width=10, height=10)
    agent = AgentNetwork()

    genome = agent.get_genome()

    print("=" * 60)
    print("LAYER 1: 6-8-12-4 AGENT")
    print("=" * 60)

    print(f"Number of network parameters: {len(genome)}")
    print(f"Starting agent position: ({simulator.agent_x}, "
          f"{simulator.agent_y})")
    print(f"Starting target position: ({simulator.target_x}, "
          f"{simulator.target_y})")
    print()

    action_names = [
        "UP",
        "DOWN",
        "LEFT",
        "RIGHT",
    ]

    for step_number in range(number_of_steps):

        # 1. Simulator produces six values.
        observations = simulator.get_observations()

        # 2. Neural network produces four action scores.
        action_scores = agent.forward(observations)

        # 3. Select the action with the highest score.
        selected_action = agent.choose_action(observations)

        # 4. Send that action back to the simulator.
        simulator.take_action(selected_action)

        # Print the first ten steps so we can inspect the network.
        if step_number < 10:
            rounded_observations = [
                round(value, 3)
                for value in observations
            ]

            rounded_scores = [
                round(value, 3)
                for value in action_scores
            ]

            print(f"Step {step_number + 1}")
            print(f"  Observations: {rounded_observations}")
            print(f"  Action scores: {rounded_scores}")
            print(f"  Selected action: "
                  f"{action_names[selected_action]}")
            print(f"  Agent position: "
                  f"({simulator.agent_x}, {simulator.agent_y})")
            print()

    print("=" * 60)
    print("RESULTS AFTER 200 STEPS")
    print("=" * 60)
    print(f"Targets reached: {simulator.targets_reached}")
    print(f"Wall collisions: {simulator.collisions}")
    print(f"Distance moved: {simulator.total_distance_moved}")
    print(f"Final distance to target: "
          f"{simulator.distance_to_target()}")
    print()
    print("The behavior is probably poor because the weights are random.")
    print("Layer 2 will later evolve the 216 parameters.")


# ============================================================
# PROGRAM ENTRY POINT
# ============================================================

if __name__ == "__main__":

    # Keeping the same seed gives the same random network each run.
    # Remove this line later when creating a population of agents.
    random.seed(42)

    run_agent(number_of_steps=200)