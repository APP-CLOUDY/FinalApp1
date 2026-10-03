import re
import sys

file_path = "Programmatic 2/Child  2/Rewrads 2/RewardsHubViewController.swift"
with open(file_path, 'r') as f:
    lines = f.readlines()

# Replace coinBadgeView lines 28-46
# Find exact start and end of coinBadgeView
start_badge = -1
end_badge = -1
for i, line in enumerate(lines):
    if "private let coinBadgeView: UIView =" in line:
        start_badge = i
    if start_badge != -1 and "    }()" in line:
        end_badge = i
        break

replacement_badge = [
    "    private let coinBadgeView: UIView = {\n",
    "        let container = UIView()\n",
    "        container.translatesAutoresizingMaskIntoConstraints = false\n",
    "        \n",
    "        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))\n",
    "        blur.translatesAutoresizingMaskIntoConstraints = false\n",
    "        blur.layer.cornerRadius = 16\n",
    "        blur.clipsToBounds = true\n",
    "        container.addSubview(blur)\n",
    "        NSLayoutConstraint.activate([\n",
    "            blur.topAnchor.constraint(equalTo: container.topAnchor),\n",
    "            blur.bottomAnchor.constraint(equalTo: container.bottomAnchor),\n",
    "            blur.leadingAnchor.constraint(equalTo: container.leadingAnchor),\n",
    "            blur.trailingAnchor.constraint(equalTo: container.trailingAnchor)\n",
    "        ])\n",
    "        \n",
    "        container.layer.cornerRadius = 16\n",
    "        container.layer.borderWidth = 1\n",
    "        container.layer.borderColor = UIColor(white: 1.0, alpha: 0.15).cgColor\n",
    "        \n",
    "        // Premium shadow / glow\n",
    "        container.layer.shadowColor = UIColor.systemYellow.cgColor\n",
    "        container.layer.shadowOpacity = 0.25\n",
    "        container.layer.shadowRadius = 8\n",
    "        container.layer.shadowOffset = CGSize(width: 0, height: 4)\n",
    "        \n",
    "        return container\n",
    "    }()\n"
]

lines[start_badge:end_badge+1] = replacement_badge

# Find coinLabel
start_label = -1
end_label = -1
for i, line in enumerate(lines):
    if "private let coinLabel: UILabel =" in line:
        start_label = i
    if start_label != -1 and "    }()" in line and i > start_label:
        end_label = i
        break

replacement_label = [
    "    private let coinLabel: UILabel = {\n",
    "        let lb = UILabel()\n",
    "        lb.translatesAutoresizingMaskIntoConstraints = false\n",
    "        lb.text = \"\"\n",
    "        lb.font = .systemFont(ofSize: 16, weight: .black)\n",
    "        lb.textColor = UIColor(red: 255/255, green: 220/255, blue: 120/255, alpha: 1.0)\n",
    "        lb.layer.shadowColor = UIColor.systemYellow.cgColor\n",
    "        lb.layer.shadowRadius = 4\n",
    "        lb.layer.shadowOpacity = 0.6\n",
    "        lb.layer.shadowOffset = .zero\n",
    "        return lb\n",
    "    }()\n"
]

lines[start_label:end_label+1] = replacement_label

with open(file_path, 'w') as f:
    f.writelines(lines)
