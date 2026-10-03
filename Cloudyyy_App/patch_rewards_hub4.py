import re
import sys

file_path = "Programmatic 2/Child  2/Rewrads 2/RewardsHubViewController.swift"
with open(file_path, 'r') as f:
    lines = f.readlines()

# Find coinBadgeView
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
    "        // Subtle clean border\n",
    "        container.layer.cornerRadius = 16\n",
    "        container.layer.borderWidth = 0.5\n",
    "        container.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor\n",
    "        \n",
    "        // Natural subtle drop shadow (no neon)\n",
    "        container.layer.shadowColor = UIColor.black.cgColor\n",
    "        container.layer.shadowOpacity = 0.2\n",
    "        container.layer.shadowRadius = 4\n",
    "        container.layer.shadowOffset = CGSize(width: 0, height: 2)\n",
    "        \n",
    "        return container\n",
    "    }()\n"
]
lines[start_badge:end_badge+1] = replacement_badge

# Find starIcon
start_star = -1
end_star = -1
for i, line in enumerate(lines):
    if "private let starIcon: UIImageView =" in line:
        start_star = i
    if start_star != -1 and "    }()" in line and i > start_star:
        end_star = i
        break

replacement_star = [
    "    private let starIcon: UIImageView = {\n",
    "        let iv = UIImageView()\n",
    "        iv.translatesAutoresizingMaskIntoConstraints = false\n",
    "        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)\n",
    "        let paletteConfig = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemOrange])\n",
    "        let combined = config.applying(paletteConfig)\n",
    "        \n",
    "        iv.image = UIImage(systemName: \"star.circle.fill\", withConfiguration: combined)\n",
    "        iv.contentMode = .scaleAspectFit\n",
    "        return iv\n",
    "    }()\n"
]
lines[start_star:end_star+1] = replacement_star

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
    "        lb.font = .systemFont(ofSize: 15, weight: .semibold)\n",
    "        lb.textColor = .white\n",
    "        return lb\n",
    "    }()\n"
]
lines[start_label:end_label+1] = replacement_label

with open(file_path, 'w') as f:
    f.writelines(lines)
