# Financial Pandemic Risk Simulator (SIRD-Model)
This Julia-based project simulates the spread of a pandemic using an expanded SIRD **(Susceptible-Infected-Recovered-Deceased)** model. It integrates real-world demographic data via a REST API to estimate both the biological progression and the resulting financial liabilities for insurance portfolios.

## Features
- **Real-world Data:** Automatically fetches the latest population data for any country using the `restcountries.com`API.
- **Actuarial Component:** Beyond standard epidemiology, the model tracks cumulative financial impact, including daily healthcare costs and life insurance payouts.
- **Numerical precision:** Utilizes the `DifferentialEquations.jl` suitable for high-performance solving of non-linear ODEs.
- **Visual Analysis:** Generates dual-axis plots to compare viral spread with economic loss.

## The Model
The dynamics are governed by the following system of Ordinary Differential Equations (ODEs):
$$
\begin{aligned}
\frac{dS}{dt} &= \Delta N - \beta \frac{SI}{N} \\
\frac{dI}{dt} &= \beta \frac{SI}{N} - (\gamma + \mu)I \\
\frac{dR}{dt} &= \gamma I \\
\frac{dD}{dt} &= \mu I \\
\frac{dC}{dt} &= I \cdot \text{cost}_{\text{day}} + \frac{dD}{dt} \cdot \text{payout}
\end{aligned}
$$

Where:
- **S, I, R, D:** Suspectible, Infected, Recovered, Deceased
- **C:** Cumulative Financial Cost
- **$\beta$, $\gamma$, $\mu$:** Rates for infection, recovery, and mortality
- **$\Delta$:** Proportional birth/migration rate

## How to use
1. **Clone the repository:** `git clone https://github.com/lasfun/Pandemic-Risk-Simulator.git`
2. **Install Dependencies:** Open Julia and run: `using Pkg\nPkg.add(["DifferentialEquations", "Plots", "HTTP", "JSON3"])`
3. **Run the simulation:** `include("main.jl")`
## Example Output
The simulation provides a visualization of the pandemic curve (top) and the corresponding financial risk exposure (bottom), allowing for stress-testing of different mortality and cost scenarios.