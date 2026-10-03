import re
import sys

file_path = "Programmatic 2/Child  2/Rewrads 2/RewardsHubViewController.swift"
with open(file_path, 'r') as f:
    lines = f.readlines()

# Replace coinBadgeView lines 28-44
lines[28:44] = [
    "    // Coin Badge Container\n",
    "    private let coinBadgeView: UIView = {\n",
    "        let v = UIView()\n",
    "        v.translatesAutoresizingMaskIntoConstraints = false\n",
    "        v.backgroundColor = UIColor(white: 0.12, alpha: 0.85) // Dark pill\n",
    "        v.layer.cornerRadius = 16\n",
    "        v.layer.borderWidth = 1\n",
    "        v.layer.borderColor = UIColor(white: 0.3, alpha: 1.0).cgColor\n",
    "        \n",
    "        v.isUserInteractionEnabled = false\n",
    "        \n",
    "        // ✨ Subtle shadow\n",
    "        v.layer.shadowColor = UIColor.black.cgColor\n",
    "        v.layer.shadowOpacity = 0.3\n",
    "        v.layer.shadowRadius = 4\n",
    "        v.layer.shadowOffset = CGSize(width: 0, height: 2)\n",
    "        \n",
    "        return v\n",
    "    }()\n"
]

# Replace starIcon and coinLabel lines 180-198 (need to adjust line offset due to +2 lines inserted)
# 44 - 28 = 16 lines replaced with 19 lines (+3 lines shift). 
# Lines 180 becomes 183 to 201
lines[183:201] = [
    "    private let starIcon: UIImageView = {\n",
    "        let iv = UIImageView()\n",
    "        iv.translatesAutoresizingMaskIntoConstraints = false\n",
    "        // 3D Coin look\n",
    "        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)\n",
    "        let paletteConfig = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemOrange])\n",
    "        let combined = config.applying(paletteConfig)\n",
    "        \n",
    "        iv.image = UIImage(systemName: \"star.circle.fill\", withConfiguration: combined)\n",
    "        \n",
    "        iv.layer.shadowColor = UIColor.systemYellow.cgColor\n",
    "        iv.layer.shadowRadius = 3\n",
    "        iv.layer.shadowOpacity = 0.5\n",
    "        iv.layer.shadowOffset = .zero\n",
    "        \n",
    "        iv.contentMode = .scaleAspectFit\n",
    "        return iv\n",
    "    }()\n",
    "    \n",
    "    private let coinLabel: UILabel = {\n",
    "        let lb = UILabel()\n",
    "        lb.translatesAutoresizingMaskIntoConstraints = false\n",
    "        lb.text = \"\"\n",
    "        lb.font = .systemFont(ofSize: 15, weight: .heavy)\n",
    "        lb.textColor = .white\n",
    "        return lb\n",
    "    }()\n"
]

# Constraints were at 671 to 686 -> +3 lines -> +6 lines -> 677 to 692.
# +3 from block 1. Block 2: 18 -> 27 (+9). Total offset +12.
# 671 becomes 683. 686 becomes 698.
lines[683:699] = [
    "            // COIN BADGE\n",
    "            coinBadgeView.trailingAnchor.constraint(equalTo: profileAvatarButton.leadingAnchor, constant: -16),\n",
    "            coinBadgeView.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),\n",
    "            coinBadgeView.heightAnchor.constraint(equalToConstant: 32),\n",
    "            coinBadgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),\n",
    "\n",
    "            // ⭐ Star Icon\n",
    "            starIcon.leadingAnchor.constraint(equalTo: coinBadgeView.leadingAnchor, constant: 8),\n",
    "            starIcon.centerYAnchor.constraint(equalTo: coinBadgeView.centerYAnchor),\n",
    "            starIcon.widthAnchor.constraint(equalToConstant: 18),\n",
    "            starIcon.heightAnchor.constraint(equalToConstant: 18),\n",
    "            \n",
    "            // ⭐ Coin Label\n",
    "            coinLabel.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 6),\n",
    "            coinLabel.trailingAnchor.constraint(equalTo: coinBadgeView.trailingAnchor, constant: -12),\n",
    "            coinLabel.centerYAnchor.constraint(equalTo: coinBadgeView.centerYAnchor),\n"
]

with open(file_path, 'w') as f:
    f.writelines(lines)
