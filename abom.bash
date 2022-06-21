ABOM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

# shellcheck source=./abom_lib.bash
source "${ABOM_DIR}/abom_lib.bash"
# shellcheck source=./abom_struct.bash
source "${ABOM_DIR}/abom_struct.bash"
# shellcheck source=./abom_components.bash
source "${ABOM_DIR}/abom_components.bash"
