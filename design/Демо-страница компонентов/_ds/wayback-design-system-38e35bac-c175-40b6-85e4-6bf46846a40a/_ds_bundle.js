/* @ds-bundle: {"format":4,"namespace":"WaybackDesignSystem_38e35b","components":[{"name":"Button","sourcePath":"components/actions/Button.jsx"},{"name":"IconButton","sourcePath":"components/actions/IconButton.jsx"},{"name":"Avatar","sourcePath":"components/content/Avatar.jsx"},{"name":"Badge","sourcePath":"components/content/Badge.jsx"},{"name":"Card","sourcePath":"components/content/Card.jsx"},{"name":"Chip","sourcePath":"components/content/Chip.jsx"},{"name":"Divider","sourcePath":"components/content/Divider.jsx"},{"name":"ListItem","sourcePath":"components/content/ListItem.jsx"},{"name":"Alert","sourcePath":"components/feedback/Alert.jsx"},{"name":"BottomSheet","sourcePath":"components/feedback/BottomSheet.jsx"},{"name":"Dialog","sourcePath":"components/feedback/Dialog.jsx"},{"name":"ProgressIndicator","sourcePath":"components/feedback/ProgressIndicator.jsx"},{"name":"Skeleton","sourcePath":"components/feedback/Skeleton.jsx"},{"name":"Snackbar","sourcePath":"components/feedback/Snackbar.jsx"},{"name":"Checkbox","sourcePath":"components/forms/Checkbox.jsx"},{"name":"Radio","sourcePath":"components/forms/Radio.jsx"},{"name":"Switch","sourcePath":"components/forms/Switch.jsx"},{"name":"TextArea","sourcePath":"components/forms/TextArea.jsx"},{"name":"TextField","sourcePath":"components/forms/TextField.jsx"},{"name":"POINT_TYPES","sourcePath":"components/forms/TypePicker.jsx"},{"name":"TypePicker","sourcePath":"components/forms/TypePicker.jsx"},{"name":"Icon","sourcePath":"components/foundations/Icon.jsx"},{"name":"AppBar","sourcePath":"components/navigation/AppBar.jsx"},{"name":"BackButton","sourcePath":"components/navigation/BackButton.jsx"},{"name":"BottomNav","sourcePath":"components/navigation/BottomNav.jsx"},{"name":"SegmentedTabs","sourcePath":"components/navigation/SegmentedTabs.jsx"},{"name":"CompassArrow","sourcePath":"components/wayfinding/CompassArrow.jsx"}],"sourceHashes":{"components/actions/Button.jsx":"0e798ef609c7","components/actions/IconButton.jsx":"978c50112e83","components/content/Avatar.jsx":"f835fb6b4b00","components/content/Badge.jsx":"055d25e78adb","components/content/Card.jsx":"4e93015f58fc","components/content/Chip.jsx":"f81a79e50b94","components/content/Divider.jsx":"cea24fb6d727","components/content/ListItem.jsx":"1006eeeeafb8","components/feedback/Alert.jsx":"7de0d5bf533a","components/feedback/BottomSheet.jsx":"e2741afe5f3a","components/feedback/Dialog.jsx":"5cbef5b0429c","components/feedback/ProgressIndicator.jsx":"7927d148f355","components/feedback/Skeleton.jsx":"de55690c8a34","components/feedback/Snackbar.jsx":"02960e800824","components/forms/Checkbox.jsx":"2c3ff601e3d7","components/forms/Radio.jsx":"16eb5170f3aa","components/forms/Switch.jsx":"cd41aa2117d6","components/forms/TextArea.jsx":"991b5d5e0e77","components/forms/TextField.jsx":"f341397eb990","components/forms/TypePicker.jsx":"3a642fcfbe0d","components/foundations/Icon.jsx":"4d71c8b966d8","components/navigation/AppBar.jsx":"4963b0135a10","components/navigation/BackButton.jsx":"cd872a54314c","components/navigation/BottomNav.jsx":"181dd550a2ef","components/navigation/SegmentedTabs.jsx":"985a4a1580bd","components/wayfinding/CompassArrow.jsx":"be8fe7d4b4ca","ui_kits/wayback-app/App.jsx":"4e96c7db6e5f","ui_kits/wayback-app/NavigateScreen.jsx":"d2c289a7d5f1","ui_kits/wayback-app/PermissionScreen.jsx":"8f99d5cdaba7","ui_kits/wayback-app/PhoneFrame.jsx":"59b68e199d3b","ui_kits/wayback-app/PointsScreen.jsx":"bc399af47914","ui_kits/wayback-app/SaveSheet.jsx":"12e1d620c0e5","ui_kits/wayback-app/SettingsScreen.jsx":"e9d29ed304c0"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.WaybackDesignSystem_38e35b = window.WaybackDesignSystem_38e35b || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/content/Avatar.jsx
try { (() => {
function Avatar({
  name = '',
  size = 44,
  tone = 'brand',
  style
}) {
  const letter = (name.trim()[0] || '?').toUpperCase();
  const tones = {
    brand: {
      background: 'var(--wb-brand-600)',
      color: 'var(--wb-content-on-brand)'
    },
    neutral: {
      background: 'var(--wb-surface-container)',
      color: 'var(--wb-content-secondary)'
    }
  };
  return /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      width: size,
      height: size,
      borderRadius: 'var(--wb-radius-full)',
      flexShrink: 0,
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontFamily: 'var(--wb-font)',
      fontWeight: 700,
      fontSize: Math.round(size * 0.4),
      ...(tones[tone] || tones.brand),
      ...style
    }
  }, letter);
}
Object.assign(__ds_scope, { Avatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/content/Avatar.jsx", error: String((e && e.message) || e) }); }

// components/content/Badge.jsx
try { (() => {
function Badge({
  children,
  tone = 'neutral',
  style
}) {
  const tones = {
    positive: {
      background: 'var(--wb-positive-bg)',
      color: 'var(--wb-positive)'
    },
    warning: {
      background: 'color-mix(in srgb, var(--wb-warning-bg) 22%, transparent)',
      color: 'var(--wb-warning)'
    },
    negative: {
      background: 'var(--wb-negative-bg)',
      color: 'var(--wb-negative)'
    },
    brand: {
      background: 'var(--wb-brand-600)',
      color: 'var(--wb-content-on-brand)'
    },
    neutral: {
      background: 'var(--wb-surface-container)',
      color: 'var(--wb-content-secondary)'
    }
  };
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      fontFamily: 'var(--wb-font)',
      fontSize: 11.5,
      fontWeight: 700,
      padding: '4px 10px',
      borderRadius: 'var(--wb-radius-full)',
      ...(tones[tone] || tones.neutral),
      ...style
    }
  }, children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/content/Badge.jsx", error: String((e && e.message) || e) }); }

// components/content/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Card({
  children,
  elevation = 2,
  padding = 'var(--wb-space-xl)',
  style,
  ...rest
}) {
  const shadows = {
    1: 'none',
    2: 'var(--wb-shadow-1)',
    3: 'var(--wb-shadow-2)'
  };
  return /*#__PURE__*/React.createElement("div", _extends({}, rest, {
    style: {
      background: elevation === 1 ? 'var(--wb-surface-container)' : 'var(--wb-surface-elevated)',
      borderRadius: 'var(--wb-radius-lg)',
      padding,
      boxShadow: shadows[elevation] || shadows[2],
      border: elevation === 1 ? 'none' : '1px solid var(--wb-border-subtle)',
      fontFamily: 'var(--wb-font)',
      color: 'var(--wb-content-primary)',
      ...style
    }
  }), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/content/Card.jsx", error: String((e && e.message) || e) }); }

// components/content/Divider.jsx
try { (() => {
function Divider({
  inset = 0,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    role: "separator",
    style: {
      height: 1,
      background: 'var(--wb-border-subtle)',
      marginLeft: inset,
      ...style
    }
  });
}
Object.assign(__ds_scope, { Divider });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/content/Divider.jsx", error: String((e && e.message) || e) }); }

// components/feedback/BottomSheet.jsx
try { (() => {
function BottomSheet({
  title,
  children,
  platform = 'ios',
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: '100%',
      maxWidth: 400,
      background: 'var(--wb-surface-elevated)',
      borderRadius: 'var(--wb-radius-lg) var(--wb-radius-lg) 0 0',
      boxShadow: 'var(--wb-shadow-3)',
      fontFamily: 'var(--wb-font)',
      paddingTop: 'var(--wb-space-sm)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: platform === 'android' ? 32 : 36,
      height: 4,
      borderRadius: 999,
      background: 'var(--wb-border-default)',
      opacity: 0.6,
      margin: '0 auto var(--wb-space-md)'
    }
  }), title ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 700,
      fontSize: 16,
      textAlign: 'center',
      color: 'var(--wb-content-primary)',
      paddingBottom: 'var(--wb-space-md)'
    }
  }, title) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 var(--wb-space-md) var(--wb-space-xl)'
    }
  }, children));
}
Object.assign(__ds_scope, { BottomSheet });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/BottomSheet.jsx", error: String((e && e.message) || e) }); }

// components/feedback/ProgressIndicator.jsx
try { (() => {
function ProgressIndicator({
  value,
  label,
  size = 20,
  style
}) {
  const determinate = typeof value === 'number';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--wb-space-sm)',
      fontFamily: 'var(--wb-font)',
      ...style
    }
  }, determinate ? /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      height: 4,
      borderRadius: 999,
      background: 'var(--wb-surface-sunken)',
      overflow: 'hidden',
      minWidth: 120
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: `${Math.max(0, Math.min(100, value))}%`,
      height: '100%',
      background: 'var(--wb-brand-600)'
    }
  })) : /*#__PURE__*/React.createElement("span", {
    style: {
      width: size,
      height: size,
      borderRadius: 999,
      display: 'inline-block',
      border: '2.5px solid var(--wb-surface-sunken)',
      borderTopColor: 'var(--wb-brand-600)',
      animation: 'wb-spin 0.8s linear infinite'
    }
  }), label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      color: 'var(--wb-content-secondary)'
    }
  }, label) : null, /*#__PURE__*/React.createElement("style", null, '@keyframes wb-spin{to{transform:rotate(360deg)}}'));
}
Object.assign(__ds_scope, { ProgressIndicator });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/ProgressIndicator.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Skeleton.jsx
try { (() => {
function Skeleton({
  width = '100%',
  height = 16,
  radius = 'var(--wb-radius-sm)',
  style
}) {
  return /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      display: 'inline-block',
      width,
      height,
      borderRadius: radius,
      background: 'linear-gradient(90deg, var(--wb-surface-container) 25%, var(--wb-surface-sunken) 37%, var(--wb-surface-container) 63%)',
      backgroundSize: '400% 100%',
      animation: 'wb-shimmer var(--wb-shimmer-duration) ease infinite',
      ...style
    }
  }, /*#__PURE__*/React.createElement("style", null, '@keyframes wb-shimmer{0%{background-position:100% 0}100%{background-position:0 0}}'));
}
Object.assign(__ds_scope, { Skeleton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Skeleton.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Snackbar.jsx
try { (() => {
function Snackbar({
  children,
  actionLabel,
  onAction,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    role: "status",
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      gap: 'var(--wb-space-md)',
      maxWidth: 420,
      padding: '14px 18px',
      background: 'var(--wb-content-primary)',
      color: 'var(--wb-surface-default)',
      borderRadius: 'var(--wb-radius-md)',
      boxShadow: 'var(--wb-shadow-2)',
      fontFamily: 'var(--wb-font)',
      fontSize: 14,
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", null, children), actionLabel ? /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onAction,
    style: {
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      color: 'var(--wb-brand-500)',
      fontWeight: 700,
      fontFamily: 'var(--wb-font)',
      fontSize: 14
    }
  }, actionLabel) : null);
}
Object.assign(__ds_scope, { Snackbar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Snackbar.jsx", error: String((e && e.message) || e) }); }

// components/forms/Radio.jsx
try { (() => {
function Radio({
  checked = false,
  onChange,
  label,
  disabled = false,
  style
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 'var(--wb-space-sm)',
      minHeight: 44,
      fontFamily: 'var(--wb-font)',
      fontSize: 15,
      color: 'var(--wb-content-primary)',
      cursor: disabled ? 'default' : 'pointer',
      opacity: disabled ? 0.6 : 1,
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    role: "radio",
    "aria-checked": checked,
    "aria-disabled": disabled || undefined,
    tabIndex: 0,
    onClick: () => !disabled && onChange && onChange(true),
    style: {
      width: 22,
      height: 22,
      borderRadius: 999,
      flexShrink: 0,
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      border: `2px solid ${checked ? 'var(--wb-action-primary-bg)' : 'var(--wb-border-default)'}`
    }
  }, checked ? /*#__PURE__*/React.createElement("span", {
    style: {
      width: 11,
      height: 11,
      borderRadius: 999,
      background: 'var(--wb-action-primary-bg)'
    }
  }) : null), label);
}
Object.assign(__ds_scope, { Radio });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Radio.jsx", error: String((e && e.message) || e) }); }

// components/forms/Switch.jsx
try { (() => {
/* Platform-adaptive: iOS = CupertinoSwitch geometry, Android = Material geometry.
   Brand fill on both; the mechanics differ, the identity does not. */
function Switch({
  checked = false,
  onChange,
  platform = 'ios',
  disabled = false,
  label,
  style
}) {
  const ios = platform !== 'android';
  const trackW = ios ? 51 : 44;
  const trackH = ios ? 31 : 26;
  const thumb = ios ? 27 : 22;
  const control = /*#__PURE__*/React.createElement("span", {
    role: "switch",
    "aria-checked": checked,
    "aria-disabled": disabled || undefined,
    tabIndex: 0,
    onClick: () => !disabled && onChange && onChange(!checked),
    style: {
      width: trackW,
      height: trackH,
      borderRadius: 999,
      position: 'relative',
      display: 'inline-block',
      flexShrink: 0,
      cursor: disabled ? 'default' : 'pointer',
      background: checked ? 'var(--wb-action-primary-bg)' : 'var(--wb-surface-sunken)',
      border: checked ? 'none' : '1px solid var(--wb-border-subtle)',
      transition: 'background var(--wb-duration-fast)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      top: 2,
      left: checked ? trackW - thumb - 2 : 2,
      width: thumb,
      height: thumb,
      borderRadius: 999,
      background: '#FFFFFF',
      boxShadow: '0 1px 2px rgba(0,0,0,0.25)',
      transition: 'left var(--wb-duration-fast)'
    }
  }));
  if (!label) return React.cloneElement(control, {
    style: {
      ...control.props.style,
      opacity: disabled ? 0.6 : 1,
      ...style
    }
  });
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 'var(--wb-space-md)',
      minHeight: 44,
      fontFamily: 'var(--wb-font)',
      fontSize: 15,
      color: 'var(--wb-content-primary)',
      opacity: disabled ? 0.6 : 1,
      ...style
    }
  }, control, label);
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Switch.jsx", error: String((e && e.message) || e) }); }

// components/forms/TextArea.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function TextArea({
  label,
  value,
  onChange,
  placeholder,
  helper,
  error,
  rows = 3,
  disabled = false,
  style,
  ...rest
}) {
  const [focused, setFocused] = React.useState(false);
  const borderColor = error ? 'var(--wb-negative)' : focused ? 'var(--wb-border-focus)' : 'var(--wb-border-default)';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      fontFamily: 'var(--wb-font)',
      opacity: disabled ? 0.6 : 1,
      ...style
    }
  }, label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11.5,
      fontWeight: 600,
      color: 'var(--wb-content-tertiary)',
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      marginBottom: 6
    }
  }, label) : null, /*#__PURE__*/React.createElement("textarea", _extends({
    rows: rows,
    value: value,
    placeholder: placeholder,
    disabled: disabled,
    onChange: e => onChange && onChange(e.target.value),
    onFocus: () => setFocused(true),
    onBlur: () => setFocused(false)
  }, rest, {
    style: {
      resize: 'vertical',
      padding: '12px 14px',
      borderRadius: 'var(--wb-radius-md)',
      background: disabled ? 'var(--wb-surface-container)' : 'var(--wb-surface-default)',
      border: `${focused || error ? 'var(--wb-border-thick)' : 'var(--wb-border-thin)'} solid ${borderColor}`,
      fontFamily: 'var(--wb-font)',
      fontSize: 15,
      lineHeight: '22px',
      color: 'var(--wb-content-primary)',
      outline: 'none'
    }
  })), error || helper ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      marginTop: 6,
      color: error ? 'var(--wb-negative)' : 'var(--wb-content-tertiary)'
    }
  }, error || helper) : null);
}
Object.assign(__ds_scope, { TextArea });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/TextArea.jsx", error: String((e && e.message) || e) }); }

// components/foundations/Icon.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* Material Symbols Outlined, weight 400, unfilled — the app's single icon set.
   Requires the Material Symbols webfont from tokens/fonts.css. */
function Icon({
  name,
  size = 24,
  color = 'currentColor',
  weight = 400,
  fill = 0,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("span", _extends({
    "aria-hidden": "true"
  }, rest, {
    style: {
      fontFamily: '"Material Symbols Outlined"',
      fontWeight: 'normal',
      fontStyle: 'normal',
      fontSize: size,
      lineHeight: 1,
      letterSpacing: 'normal',
      textTransform: 'none',
      whiteSpace: 'nowrap',
      display: 'inline-block',
      color,
      flexShrink: 0,
      WebkitFontSmoothing: 'antialiased',
      fontVariationSettings: `"FILL" ${fill}, "wght" ${weight}, "GRAD" 0, "opsz" ${size}`,
      ...style
    }
  }), name);
}
Object.assign(__ds_scope, { Icon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/foundations/Icon.jsx", error: String((e && e.message) || e) }); }

// components/actions/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const SIZES = {
  medium: {
    minHeight: 44,
    padding: '12px 20px',
    fontSize: 14.5
  },
  small: {
    minHeight: 36,
    padding: '8px 16px',
    fontSize: 13.5
  }
};
function Button({
  children,
  variant = 'primary',
  size = 'medium',
  icon,
  loading = false,
  disabled = false,
  onClick,
  style,
  ...rest
}) {
  const s = SIZES[size] || SIZES.medium;
  const base = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 'var(--wb-space-xs)',
    fontFamily: 'var(--wb-font)',
    fontWeight: 600,
    fontSize: s.fontSize,
    minHeight: s.minHeight,
    padding: s.padding,
    borderRadius: 'var(--wb-radius-md)',
    border: 'none',
    cursor: disabled ? 'default' : 'pointer',
    opacity: disabled ? 0.6 : 1,
    transition: 'background var(--wb-duration-fast), color var(--wb-duration-fast)'
  };
  const variants = {
    primary: {
      background: 'var(--wb-action-primary-bg)',
      color: 'var(--wb-action-primary-fg)'
    },
    secondary: {
      background: 'transparent',
      color: 'var(--wb-action-secondary-fg)',
      border: '1px solid var(--wb-action-secondary-border)'
    },
    tertiary: {
      background: 'transparent',
      color: 'var(--wb-brand-600)',
      padding: size === 'small' ? '8px 10px' : '12px 12px'
    },
    destructive: {
      background: 'transparent',
      color: 'var(--wb-negative)',
      border: '1px solid var(--wb-negative)'
    }
  };
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    disabled: disabled || loading,
    onClick: onClick,
    "aria-busy": loading || undefined
  }, rest, {
    style: {
      ...base,
      ...(variants[variant] || variants.primary),
      ...style
    }
  }), loading ? /*#__PURE__*/React.createElement("span", {
    style: {
      width: 16,
      height: 16,
      borderRadius: 999,
      border: '2.5px solid currentColor',
      borderTopColor: 'transparent',
      animation: 'wb-spin 0.8s linear infinite',
      display: 'inline-block'
    }
  }) : /*#__PURE__*/React.createElement(React.Fragment, null, icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size === 'small' ? 16 : 20
  }) : null, children), /*#__PURE__*/React.createElement("style", null, '@keyframes wb-spin{to{transform:rotate(360deg)}}'));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/actions/Button.jsx", error: String((e && e.message) || e) }); }

// components/actions/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function IconButton({
  icon,
  label,
  variant = 'ghost',
  size = 24,
  disabled = false,
  onClick,
  style,
  ...rest
}) {
  const colors = {
    ghost: {
      background: 'transparent',
      color: 'var(--wb-content-primary)'
    },
    brand: {
      background: 'transparent',
      color: 'var(--wb-brand-600)'
    },
    filled: {
      background: 'var(--wb-surface-container)',
      color: 'var(--wb-content-primary)'
    },
    negative: {
      background: 'transparent',
      color: 'var(--wb-negative)'
    }
  };
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    "aria-label": label,
    title: label,
    disabled: disabled,
    onClick: onClick
  }, rest, {
    style: {
      width: 44,
      height: 44,
      minWidth: 44,
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      border: 'none',
      borderRadius: 'var(--wb-radius-full)',
      cursor: disabled ? 'default' : 'pointer',
      opacity: disabled ? 0.6 : 1,
      padding: 0,
      ...(colors[variant] || colors.ghost),
      ...style
    }
  }), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/actions/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/content/Chip.jsx
try { (() => {
function Chip({
  children,
  icon,
  selected = false,
  onClick,
  style
}) {
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-pressed": selected,
    onClick: onClick,
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 6,
      fontFamily: 'var(--wb-font)',
      fontSize: 13,
      fontWeight: 600,
      padding: '7px 13px',
      borderRadius: 'var(--wb-radius-full)',
      cursor: 'pointer',
      background: selected ? 'var(--wb-brand-600)' : 'var(--wb-surface-default)',
      color: selected ? 'var(--wb-content-on-brand)' : 'var(--wb-content-secondary)',
      border: `1px solid ${selected ? 'var(--wb-brand-600)' : 'var(--wb-border-subtle)'}`,
      ...style
    }
  }, icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 16
  }) : null, children);
}
Object.assign(__ds_scope, { Chip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/content/Chip.jsx", error: String((e && e.message) || e) }); }

// components/content/ListItem.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function ListItem({
  icon,
  title,
  subtitle,
  trailing,
  selected = false,
  onClick,
  divider = true,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("div", _extends({
    onClick: onClick
  }, rest, {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--wb-space-md)',
      padding: 'var(--wb-space-md)',
      minHeight: 64,
      fontFamily: 'var(--wb-font)',
      borderBottom: divider ? '1px solid var(--wb-border-subtle)' : 'none',
      background: selected ? 'var(--wb-surface-container)' : 'transparent',
      boxShadow: selected ? 'inset 3px 0 0 var(--wb-brand-600)' : 'none',
      cursor: onClick ? 'pointer' : 'default',
      ...style
    }
  }), icon ? /*#__PURE__*/React.createElement("span", {
    style: {
      width: 40,
      height: 40,
      borderRadius: 999,
      flexShrink: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: selected ? 'var(--wb-brand-600)' : 'var(--wb-surface-container)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 20,
    color: selected ? 'var(--wb-content-on-brand)' : 'var(--wb-content-secondary)'
  })) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 600,
      fontSize: 15.5,
      color: 'var(--wb-content-primary)',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), subtitle ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--wb-content-secondary)',
      marginTop: 1
    }
  }, subtitle) : null), trailing ? /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      flexShrink: 0
    }
  }, trailing) : null);
}
Object.assign(__ds_scope, { ListItem });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/content/ListItem.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Alert.jsx
try { (() => {
const TONES = {
  warning: {
    bg: 'color-mix(in srgb, var(--wb-warning-bg) 16%, var(--wb-surface-default))',
    fg: 'var(--wb-warning)',
    icon: 'warning'
  },
  negative: {
    bg: 'var(--wb-negative-bg)',
    fg: 'var(--wb-negative)',
    icon: 'error'
  },
  positive: {
    bg: 'var(--wb-positive-bg)',
    fg: 'var(--wb-positive)',
    icon: 'check_circle'
  }
};
function Alert({
  tone = 'warning',
  title,
  children,
  icon,
  style
}) {
  const t = TONES[tone] || TONES.warning;
  return /*#__PURE__*/React.createElement("div", {
    role: tone === 'negative' ? 'alert' : 'status',
    style: {
      display: 'flex',
      gap: 10,
      alignItems: 'flex-start',
      maxWidth: 440,
      padding: '12px 14px',
      borderRadius: 'var(--wb-radius-md)',
      background: t.bg,
      color: t.fg,
      fontFamily: 'var(--wb-font)',
      fontSize: 13.5,
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon || t.icon,
    size: 20
  }), /*#__PURE__*/React.createElement("div", null, title ? /*#__PURE__*/React.createElement("b", {
    style: {
      display: 'block',
      marginBottom: 1
    }
  }, title) : null, children));
}
Object.assign(__ds_scope, { Alert });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Alert.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Dialog.jsx
try { (() => {
/* Platform-adaptive confirm dialog: CupertinoAlertDialog geometry on iOS,
   Material AlertDialog on Android. Same tokens on both. */
function Dialog({
  title,
  body,
  platform = 'ios',
  destructive = false,
  confirmLabel = 'Удалить',
  cancelLabel = 'Отмена',
  onConfirm,
  onCancel,
  style
}) {
  const ios = platform !== 'android';
  const btn = {
    flex: ios ? 1 : 'none',
    border: 'none',
    background: 'transparent',
    padding: 13,
    fontFamily: 'var(--wb-font)',
    fontWeight: 600,
    fontSize: 15,
    cursor: 'pointer'
  };
  return /*#__PURE__*/React.createElement("div", {
    role: "dialog",
    "aria-modal": "true",
    style: {
      width: ios ? 280 : 300,
      background: 'var(--wb-surface-elevated)',
      borderRadius: ios ? 'var(--wb-radius-lg)' : 'var(--wb-radius-dialog-android)',
      boxShadow: 'var(--wb-shadow-3)',
      overflow: 'hidden',
      fontFamily: 'var(--wb-font)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: ios ? 'var(--wb-space-lg) var(--wb-space-lg) 4px' : 'var(--wb-space-xl) var(--wb-space-lg) 4px',
      fontWeight: 700,
      fontSize: ios ? 17 : 20,
      textAlign: ios ? 'center' : 'left',
      color: 'var(--wb-content-primary)'
    }
  }, title), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: ios ? '0 var(--wb-space-lg) var(--wb-space-lg)' : '0 var(--wb-space-lg) var(--wb-space-xl)',
      fontSize: ios ? 13 : 14,
      textAlign: ios ? 'center' : 'left',
      color: 'var(--wb-content-secondary)'
    }
  }, body), ios ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      borderTop: '1px solid var(--wb-border-subtle)'
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onCancel,
    style: {
      ...btn,
      borderRight: '1px solid var(--wb-border-subtle)',
      color: 'var(--wb-brand-600)',
      fontWeight: 400
    }
  }, cancelLabel), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onConfirm,
    style: {
      ...btn,
      color: destructive ? 'var(--wb-negative)' : 'var(--wb-brand-600)',
      fontWeight: 700
    }
  }, confirmLabel)) : /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      justifyContent: 'flex-end',
      gap: 'var(--wb-space-sm)',
      padding: '0 var(--wb-space-md) var(--wb-space-md)'
    }
  }, /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onCancel,
    style: {
      ...btn,
      color: 'var(--wb-brand-600)',
      textTransform: 'uppercase',
      fontSize: 13,
      letterSpacing: '0.03em'
    }
  }, cancelLabel), /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onConfirm,
    style: {
      ...btn,
      color: destructive ? 'var(--wb-negative)' : 'var(--wb-brand-600)',
      textTransform: 'uppercase',
      fontSize: 13,
      letterSpacing: '0.03em'
    }
  }, confirmLabel)));
}
Object.assign(__ds_scope, { Dialog });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Dialog.jsx", error: String((e && e.message) || e) }); }

// components/forms/Checkbox.jsx
try { (() => {
function Checkbox({
  checked = false,
  onChange,
  label,
  disabled = false,
  style
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 'var(--wb-space-sm)',
      minHeight: 44,
      fontFamily: 'var(--wb-font)',
      fontSize: 15,
      color: 'var(--wb-content-primary)',
      cursor: disabled ? 'default' : 'pointer',
      opacity: disabled ? 0.6 : 1,
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    role: "checkbox",
    "aria-checked": checked,
    "aria-disabled": disabled || undefined,
    tabIndex: 0,
    onClick: () => !disabled && onChange && onChange(!checked),
    style: {
      width: 22,
      height: 22,
      borderRadius: 6,
      flexShrink: 0,
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: checked ? 'var(--wb-action-primary-bg)' : 'transparent',
      border: checked ? 'none' : '2px solid var(--wb-border-default)'
    }
  }, checked ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "check",
    size: 16,
    color: "var(--wb-content-on-brand)",
    weight: 700
  }) : null), label);
}
Object.assign(__ds_scope, { Checkbox });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Checkbox.jsx", error: String((e && e.message) || e) }); }

// components/forms/TextField.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function TextField({
  label,
  value,
  onChange,
  placeholder,
  helper,
  error,
  disabled = false,
  leadingIcon,
  trailingAction,
  type = 'text',
  style,
  ...rest
}) {
  const [focused, setFocused] = React.useState(false);
  const borderColor = error ? 'var(--wb-negative)' : focused ? 'var(--wb-border-focus)' : disabled ? 'var(--wb-border-subtle)' : 'var(--wb-border-default)';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      fontFamily: 'var(--wb-font)',
      opacity: disabled ? 0.6 : 1,
      ...style
    }
  }, label ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11.5,
      fontWeight: 600,
      color: 'var(--wb-content-tertiary)',
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      marginBottom: 6
    }
  }, label) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      minHeight: 44,
      padding: '12px 14px',
      borderRadius: 'var(--wb-radius-md)',
      background: disabled ? 'var(--wb-surface-container)' : 'var(--wb-surface-default)',
      border: `${focused || error ? 'var(--wb-border-thick)' : 'var(--wb-border-thin)'} solid ${borderColor}`
    }
  }, leadingIcon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: leadingIcon,
    size: 20,
    color: "var(--wb-content-tertiary)"
  }) : null, /*#__PURE__*/React.createElement("input", _extends({
    type: type,
    value: value,
    placeholder: placeholder,
    disabled: disabled,
    onChange: e => onChange && onChange(e.target.value),
    onFocus: () => setFocused(true),
    onBlur: () => setFocused(false)
  }, rest, {
    style: {
      flex: 1,
      minWidth: 0,
      border: 'none',
      outline: 'none',
      background: 'transparent',
      fontFamily: 'var(--wb-font)',
      fontSize: 15,
      color: 'var(--wb-content-primary)',
      padding: 0
    }
  })), trailingAction ? /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center'
    }
  }, trailingAction) : null), error || helper ? /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      marginTop: 6,
      color: error ? 'var(--wb-negative)' : 'var(--wb-content-tertiary)'
    }
  }, error || helper) : null);
}
Object.assign(__ds_scope, { TextField });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/TextField.jsx", error: String((e && e.message) || e) }); }

// components/forms/TypePicker.jsx
try { (() => {
/* The fixed point-type set from docs/mvp-scope.md, as a 4x2 icon grid — deliberately
   not a dropdown: it is a small fixed set and the glyph is the whole point. */
const POINT_TYPES = [{
  id: 'car',
  icon: 'directions_car',
  label: 'Машина'
}, {
  id: 'tent',
  icon: 'camping',
  label: 'Лагерь'
}, {
  id: 'fishing',
  icon: 'phishing',
  label: 'Рыбалка'
}, {
  id: 'bag',
  icon: 'backpack',
  label: 'Вещи'
}, {
  id: 'house',
  icon: 'cottage',
  label: 'Домик'
}, {
  id: 'meeting',
  icon: 'group',
  label: 'Встреча'
}, {
  id: 'parking',
  icon: 'local_parking',
  label: 'Парковка'
}, {
  id: 'generic',
  icon: 'location_on',
  label: 'Точка'
}];
function TypePicker({
  value = 'car',
  onChange,
  types = POINT_TYPES,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    role: "radiogroup",
    style: {
      display: 'grid',
      gridTemplateColumns: 'repeat(4, 1fr)',
      gap: 'var(--wb-space-sm)',
      ...style
    }
  }, types.map(t => {
    const selected = t.id === value;
    return /*#__PURE__*/React.createElement("button", {
      key: t.id,
      type: "button",
      role: "radio",
      "aria-checked": selected,
      onClick: () => onChange && onChange(t.id),
      style: {
        aspectRatio: '1',
        borderRadius: 'var(--wb-radius-md)',
        cursor: 'pointer',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 4,
        padding: 0,
        background: selected ? 'var(--wb-brand-600)' : 'transparent',
        border: selected ? '1.5px solid var(--wb-brand-600)' : '1.5px solid var(--wb-border-subtle)',
        color: selected ? 'var(--wb-content-on-brand)' : 'var(--wb-content-secondary)'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: t.icon,
      size: 24
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--wb-font)',
        fontSize: 10.5,
        fontWeight: 600
      }
    }, t.label));
  }));
}
Object.assign(__ds_scope, { POINT_TYPES, TypePicker });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/TypePicker.jsx", error: String((e && e.message) || e) }); }

// components/navigation/BackButton.jsx
try { (() => {
/* Platform-adaptive back affordance: iOS chevron in brand colour, Android arrow in content colour. */
function BackButton({
  platform = 'ios',
  onClick,
  label = 'Назад',
  style
}) {
  const ios = platform !== 'android';
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": label,
    onClick: onClick,
    style: {
      width: 44,
      height: 44,
      minWidth: 44,
      border: 'none',
      background: 'transparent',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: ios ? 'flex-start' : 'center',
      cursor: 'pointer',
      padding: 0,
      fontFamily: 'var(--wb-font)',
      color: ios ? 'var(--wb-brand-600)' : 'var(--wb-content-primary)',
      fontSize: ios ? 30 : 20,
      lineHeight: 1,
      ...style
    }
  }, ios ? '\u2039' : '\u2190');
}
Object.assign(__ds_scope, { BackButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/BackButton.jsx", error: String((e && e.message) || e) }); }

// components/navigation/AppBar.jsx
try { (() => {
function AppBar({
  title,
  onBack,
  platform = 'ios',
  actions,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--wb-space-sm)',
      height: 56,
      padding: '0 var(--wb-space-md)',
      fontFamily: 'var(--wb-font)',
      background: 'var(--wb-surface-default)',
      borderBottom: '1px solid var(--wb-border-subtle)',
      ...style
    }
  }, onBack ? /*#__PURE__*/React.createElement(__ds_scope.BackButton, {
    platform: platform,
    onClick: onBack
  }) : null, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontWeight: 600,
      fontSize: 17,
      color: 'var(--wb-content-primary)',
      textAlign: platform === 'ios' && onBack ? 'center' : 'left',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), actions ? /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--wb-space-2xs)'
    }
  }, actions) : null);
}
Object.assign(__ds_scope, { AppBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/AppBar.jsx", error: String((e && e.message) || e) }); }

// components/navigation/BottomNav.jsx
try { (() => {
/* Specified, not used in MVP: four routes only. Kept so a later release does not invent it. */
function BottomNav({
  items = [],
  value,
  onChange,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      borderTop: '1px solid var(--wb-border-subtle)',
      background: 'var(--wb-surface-default)',
      ...style
    }
  }, items.map(it => {
    const active = it.id === value;
    return /*#__PURE__*/React.createElement("button", {
      key: it.id,
      type: "button",
      "aria-current": active || undefined,
      onClick: () => onChange && onChange(it.id),
      style: {
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: 4,
        padding: '10px 0 8px',
        border: 'none',
        background: 'transparent',
        cursor: 'pointer',
        fontFamily: 'var(--wb-font)',
        fontSize: 11,
        fontWeight: 600,
        color: active ? 'var(--wb-brand-600)' : 'var(--wb-content-tertiary)'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: it.icon,
      size: 24
    }), it.label);
  }));
}
Object.assign(__ds_scope, { BottomNav });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/BottomNav.jsx", error: String((e && e.message) || e) }); }

// components/navigation/SegmentedTabs.jsx
try { (() => {
function SegmentedTabs({
  items = [],
  value,
  onChange,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    role: "tablist",
    style: {
      display: 'inline-flex',
      gap: 2,
      padding: 3,
      borderRadius: 'var(--wb-radius-full)',
      background: 'var(--wb-surface-container)',
      ...style
    }
  }, items.map(it => {
    const active = it.id === value;
    return /*#__PURE__*/React.createElement("button", {
      key: it.id,
      type: "button",
      role: "tab",
      "aria-selected": active,
      onClick: () => onChange && onChange(it.id),
      style: {
        padding: '6px 18px',
        borderRadius: 'var(--wb-radius-full)',
        border: 'none',
        cursor: 'pointer',
        fontFamily: 'var(--wb-font)',
        fontSize: 13,
        fontWeight: 600,
        background: active ? 'var(--wb-surface-elevated)' : 'transparent',
        color: active ? 'var(--wb-content-primary)' : 'var(--wb-content-secondary)',
        boxShadow: active ? 'var(--wb-shadow-1)' : 'none'
      }
    }, it.label);
  }));
}
Object.assign(__ds_scope, { SegmentedTabs });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/SegmentedTabs.jsx", error: String((e && e.message) || e) }); }

// components/wayfinding/CompassArrow.jsx
try { (() => {
/* The one genuinely new component in the system: a continuously rotating direction
   indicator. Rotation is interpolated in short steps and never jumps through 0/360. */
function CompassArrow({
  rotation = 0,
  size = 240,
  state = 'ok',
  style
}) {
  const ringColor = state === 'arrived' ? 'var(--wb-positive)' : state === 'unreliable' ? 'var(--wb-warning)' : 'var(--wb-brand-600)';
  return /*#__PURE__*/React.createElement("div", {
    role: "img",
    "aria-label": `Направление на точку, ${Math.round(rotation)} градусов`,
    style: {
      width: size,
      height: size,
      minWidth: 200,
      borderRadius: 'var(--wb-radius-full)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      position: 'relative',
      background: 'var(--wb-surface-container)',
      border: `2px solid ${state === 'ok' ? 'var(--wb-border-subtle)' : ringColor}`,
      ...style
    }
  }, ['N', 'E', 'S', 'W'].map((c, i) => /*#__PURE__*/React.createElement("span", {
    key: c,
    style: {
      position: 'absolute',
      fontFamily: 'var(--wb-font)',
      fontSize: 11,
      fontWeight: 600,
      color: 'var(--wb-content-tertiary)',
      top: i === 0 ? 8 : i === 2 ? 'auto' : '50%',
      bottom: i === 2 ? 8 : 'auto',
      left: i === 3 ? 8 : i === 1 ? 'auto' : '50%',
      right: i === 1 ? 8 : 'auto',
      transform: i % 2 === 0 ? 'translateX(-50%)' : 'translateY(-50%)'
    }
  }, c)), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      transform: `rotate(${rotation}deg)`,
      transition: state === 'unreliable' ? 'none' : 'transform var(--wb-duration-base) var(--wb-ease-out)',
      filter: state === 'unreliable' ? 'blur(0.6px)' : 'none',
      opacity: state === 'unreliable' ? 0.7 : 1
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "navigation",
    size: Math.round(size * 0.46),
    color: ringColor,
    fill: 1
  })));
}
Object.assign(__ds_scope, { CompassArrow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/wayfinding/CompassArrow.jsx", error: String((e && e.message) || e) }); }

// ui_kits/wayback-app/App.jsx
try { (() => {
const INITIAL_POINTS = [{
  id: 'p1',
  name: 'Машина',
  type: 'car',
  distance: '640 м',
  saved: 'сохранено 2 часа назад'
}, {
  id: 'p2',
  name: 'Лагерь у реки',
  type: 'tent',
  distance: '1.4 км',
  saved: 'вчера, 19:20'
}, {
  id: 'p3',
  name: 'Место рыбалки',
  type: 'fishing',
  distance: '2.8 км',
  saved: '12 августа'
}];
function App() {
  const {
    SegmentedTabs,
    ProgressIndicator
  } = window.WaybackDesignSystem_38e35b;
  const [platform, setPlatform] = React.useState('ios');
  const [theme, setTheme] = React.useState('light');
  const [screen, setScreen] = React.useState('permission');
  const [points, setPoints] = React.useState(INITIAL_POINTS);
  const [activeId, setActiveId] = React.useState('p1');
  const [loading, setLoading] = React.useState(false);
  const [saving, setSaving] = React.useState(false);
  const [locating, setLocating] = React.useState(false);
  const [gps, setGps] = React.useState('good');
  const [arrived, setArrived] = React.useState(false);
  const [units, setUnits] = React.useState('m');
  const [vibrate, setVibrate] = React.useState(true);
  const [keepAwake, setKeepAwake] = React.useState(false);
  const active = points.find(p => p.id === activeId) || points[0] || {
    name: 'Точка'
  };
  function openPoints() {
    setLoading(true);
    setScreen('points');
    setTimeout(() => setLoading(false), 700);
  }
  function allow() {
    setLocating(true);
    setTimeout(() => {
      setLocating(false);
      setScreen('navigate');
    }, 900);
  }
  const chrome = {
    display: 'flex',
    gap: 12,
    alignItems: 'center',
    flexWrap: 'wrap'
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 20,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: chrome
  }, /*#__PURE__*/React.createElement(SegmentedTabs, {
    value: platform,
    onChange: setPlatform,
    items: [{
      id: 'ios',
      label: 'iOS'
    }, {
      id: 'android',
      label: 'Android'
    }]
  }), /*#__PURE__*/React.createElement(SegmentedTabs, {
    value: theme,
    onChange: setTheme,
    items: [{
      id: 'light',
      label: 'Светлая'
    }, {
      id: 'dark',
      label: 'Тёмная'
    }]
  }), /*#__PURE__*/React.createElement(SegmentedTabs, {
    value: screen,
    onChange: s => s === 'points' ? openPoints() : setScreen(s),
    items: [{
      id: 'permission',
      label: 'Разрешение'
    }, {
      id: 'navigate',
      label: 'Навигация'
    }, {
      id: 'points',
      label: 'Точки'
    }, {
      id: 'settings',
      label: 'Настройки'
    }]
  }), /*#__PURE__*/React.createElement(SegmentedTabs, {
    value: gps,
    onChange: setGps,
    items: [{
      id: 'good',
      label: 'GPS ок'
    }, {
      id: 'weak',
      label: 'GPS слабый'
    }]
  }), /*#__PURE__*/React.createElement(SegmentedTabs, {
    value: arrived ? 'yes' : 'no',
    onChange: v => setArrived(v === 'yes'),
    items: [{
      id: 'no',
      label: 'В пути'
    }, {
      id: 'yes',
      label: 'Прибытие'
    }]
  })), /*#__PURE__*/React.createElement(PhoneFrame, {
    platform: platform,
    theme: theme,
    label: `${platform} · ${screen}`
  }, locating ? /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(ProgressIndicator, {
    label: "\u041E\u043F\u0440\u0435\u0434\u0435\u043B\u044F\u0435\u043C \u043C\u0435\u0441\u0442\u043E\u043F\u043E\u043B\u043E\u0436\u0435\u043D\u0438\u0435\u2026"
  })) : screen === 'permission' ? /*#__PURE__*/React.createElement(PermissionScreen, {
    platform: platform,
    onAllow: allow
  }) : screen === 'navigate' ? /*#__PURE__*/React.createElement(NavigateScreen, {
    point: active,
    platform: platform,
    gps: gps,
    arrived: arrived,
    onOpenPoints: openPoints,
    onOpenSettings: () => setScreen('settings')
  }) : screen === 'points' ? /*#__PURE__*/React.createElement(PointsScreen, {
    points: points,
    activeId: activeId,
    platform: platform,
    loading: loading,
    onBack: () => setScreen('navigate'),
    onSelect: id => {
      setActiveId(id);
      setScreen('navigate');
    },
    onDelete: id => setPoints(ps => ps.filter(p => p.id !== id)),
    onSave: () => setSaving(true),
    onOpenSettings: () => setScreen('settings')
  }) : /*#__PURE__*/React.createElement(SettingsScreen, {
    platform: platform,
    onBack: () => setScreen('navigate'),
    units: units,
    setUnits: setUnits,
    vibrate: vibrate,
    setVibrate: setVibrate,
    keepAwake: keepAwake,
    setKeepAwake: setKeepAwake
  }), saving ? /*#__PURE__*/React.createElement(SaveSheet, {
    platform: platform,
    onCancel: () => setSaving(false),
    onSave: (name, type) => {
      const id = 'p' + Date.now();
      setPoints(ps => [{
        id,
        name: name || 'Точка',
        type,
        distance: '0 м',
        saved: 'только что'
      }, ...ps]);
      setActiveId(id);
      setSaving(false);
      setScreen('navigate');
    }
  }) : null));
}
Object.assign(window, {
  App,
  INITIAL_POINTS
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/wayback-app/App.jsx", error: String((e && e.message) || e) }); }

// ui_kits/wayback-app/NavigateScreen.jsx
try { (() => {
function NavigateScreen({
  point,
  platform,
  gps,
  onOpenPoints,
  onOpenSettings,
  arrived
}) {
  const {
    AppBar,
    IconButton,
    CompassArrow,
    Badge,
    Alert,
    Button,
    Icon
  } = window.WaybackDesignSystem_38e35b;
  const [rotation, setRotation] = React.useState(38);
  React.useEffect(() => {
    const id = setInterval(() => setRotation(r => r + (Math.random() * 10 - 4)), 1200);
    return () => clearInterval(id);
  }, []);
  const state = arrived ? 'arrived' : gps === 'weak' ? 'unreliable' : 'ok';
  const distance = arrived ? '18' : '640';
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(AppBar, {
    platform: platform,
    title: point.name,
    actions: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(IconButton, {
      icon: "list",
      label: "\u0421\u043E\u0445\u0440\u0430\u043D\u0451\u043D\u043D\u044B\u0435 \u0442\u043E\u0447\u043A\u0438",
      onClick: onOpenPoints
    }), /*#__PURE__*/React.createElement(IconButton, {
      icon: "settings",
      label: "\u041D\u0430\u0441\u0442\u0440\u043E\u0439\u043A\u0438",
      onClick: onOpenSettings
    }))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 'var(--wb-space-xl)',
      padding: 'var(--wb-space-md)'
    }
  }, /*#__PURE__*/React.createElement(CompassArrow, {
    rotation: rotation,
    size: 248,
    state: state
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    className: "wb-tabular",
    style: {
      fontSize: 56,
      lineHeight: '64px',
      fontWeight: 700,
      letterSpacing: '-0.02em'
    }
  }, distance, " \u043C"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      lineHeight: '16px',
      fontWeight: 500,
      letterSpacing: '0.02em',
      color: 'var(--wb-content-secondary)',
      marginTop: 2
    }
  }, "\u0434\u043E \u0442\u043E\u0447\u043A\u0438 \xAB", point.name, "\xBB \xB7 \u0430\u0437\u0438\u043C\u0443\u0442 38\xB0")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 'var(--wb-space-xs)',
      alignItems: 'center'
    }
  }, gps === 'weak' ? /*#__PURE__*/React.createElement(Badge, {
    tone: "warning"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "gps_not_fixed",
    size: 14
  }), " \u0422\u043E\u0447\u043D\u043E\u0441\u0442\u044C \xB124 \u043C") : /*#__PURE__*/React.createElement(Badge, {
    tone: "positive"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "gps_fixed",
    size: 14
  }), " \u0422\u043E\u0447\u043D\u043E\u0441\u0442\u044C \xB16 \u043C"), /*#__PURE__*/React.createElement(Badge, {
    tone: "neutral"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "wifi_off",
    size: 14
  }), " \u041E\u0444\u043B\u0430\u0439\u043D")), arrived ? /*#__PURE__*/React.createElement(Alert, {
    tone: "positive",
    title: "\u0412\u044B \u043D\u0430 \u043C\u0435\u0441\u0442\u0435"
  }, "\u041E\u0441\u0442\u0430\u043B\u043E\u0441\u044C 18 \u043C \u2014 \u0442\u043E\u0447\u043A\u0430 \u0433\u0434\u0435-\u0442\u043E \u0440\u044F\u0434\u043E\u043C \u0441 \u0432\u0430\u043C\u0438.") : null, gps === 'weak' && !arrived ? /*#__PURE__*/React.createElement(Alert, {
    tone: "warning",
    title: "\u0421\u043B\u0430\u0431\u044B\u0439 \u0441\u0438\u0433\u043D\u0430\u043B GPS"
  }, "\u041D\u0430\u043F\u0440\u0430\u0432\u043B\u0435\u043D\u0438\u0435 \u043C\u043E\u0436\u0435\u0442 \u0431\u044B\u0442\u044C \u043D\u0435\u0442\u043E\u0447\u043D\u044B\u043C. \u0412\u044B\u0439\u0434\u0438\u0442\u0435 \u043D\u0430 \u043E\u0442\u043A\u0440\u044B\u0442\u043E\u0435 \u043C\u0435\u0441\u0442\u043E.") : null), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 'var(--wb-space-md)',
      paddingBottom: 'var(--wb-space-xl)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--wb-space-sm)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    icon: "list",
    onClick: onOpenPoints,
    style: {
      width: '100%'
    }
  }, "\u0421\u043C\u0435\u043D\u0438\u0442\u044C \u0442\u043E\u0447\u043A\u0443")));
}
Object.assign(window, {
  NavigateScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/wayback-app/NavigateScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/wayback-app/PermissionScreen.jsx
try { (() => {
function PermissionScreen({
  platform,
  onAllow
}) {
  const {
    Button,
    Icon,
    Dialog
  } = window.WaybackDesignSystem_38e35b;
  const [ask, setAsk] = React.useState(false);
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      textAlign: 'center',
      gap: 'var(--wb-space-sm)',
      padding: 'var(--wb-space-xl)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "near_me",
    size: 48,
    color: "var(--wb-brand-600)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 24,
      lineHeight: '30px',
      fontWeight: 700
    }
  }, "Save a place.", /*#__PURE__*/React.createElement("br", null), "Find your way back."), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 16,
      lineHeight: '24px',
      color: 'var(--wb-content-secondary)',
      maxWidth: '34ch'
    }
  }, "Wayback \u043F\u043E\u043A\u0430\u0437\u044B\u0432\u0430\u0435\u0442 \u043D\u0430\u043F\u0440\u0430\u0432\u043B\u0435\u043D\u0438\u0435 \u0438 \u0440\u0430\u0441\u0441\u0442\u043E\u044F\u043D\u0438\u0435 \u0434\u043E \u0441\u043E\u0445\u0440\u0430\u043D\u0451\u043D\u043D\u043E\u0439 \u0442\u043E\u0447\u043A\u0438. \u0414\u043B\u044F \u044D\u0442\u043E\u0433\u043E \u043D\u0443\u0436\u0435\u043D \u0434\u043E\u0441\u0442\u0443\u043F \u043A \u0433\u0435\u043E\u043B\u043E\u043A\u0430\u0446\u0438\u0438 \u2014 \u0438\u043D\u0442\u0435\u0440\u043D\u0435\u0442 \u043D\u0435 \u043D\u0443\u0436\u0435\u043D."), /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    icon: "my_location",
    onClick: () => setAsk(true),
    style: {
      marginTop: 'var(--wb-space-md)'
    }
  }, "\u0420\u0430\u0437\u0440\u0435\u0448\u0438\u0442\u044C \u0434\u043E\u0441\u0442\u0443\u043F \u043A \u0433\u0435\u043E\u043B\u043E\u043A\u0430\u0446\u0438\u0438"), /*#__PURE__*/React.createElement(Button, {
    variant: "tertiary",
    onClick: onAllow
  }, "\u041F\u043E\u0437\u0436\u0435")), ask ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--wb-scrim)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Dialog, {
    platform: platform,
    title: "\u0414\u043E\u0441\u0442\u0443\u043F \u043A \u0432\u0430\u0448\u0435\u0439 \u0433\u0435\u043E\u043B\u043E\u043A\u0430\u0446\u0438\u0438?",
    body: "Wayback \u0438\u0441\u043F\u043E\u043B\u044C\u0437\u0443\u0435\u0442 \u043C\u0435\u0441\u0442\u043E\u043F\u043E\u043B\u043E\u0436\u0435\u043D\u0438\u0435 \u0442\u043E\u043B\u044C\u043A\u043E \u043D\u0430 \u0443\u0441\u0442\u0440\u043E\u0439\u0441\u0442\u0432\u0435, \u0447\u0442\u043E\u0431\u044B \u0441\u0447\u0438\u0442\u0430\u0442\u044C \u043D\u0430\u043F\u0440\u0430\u0432\u043B\u0435\u043D\u0438\u0435 \u0438 \u0440\u0430\u0441\u0441\u0442\u043E\u044F\u043D\u0438\u0435 \u0434\u043E \u0441\u043E\u0445\u0440\u0430\u043D\u0451\u043D\u043D\u043E\u0439 \u0442\u043E\u0447\u043A\u0438.",
    confirmLabel: "\u0420\u0430\u0437\u0440\u0435\u0448\u0438\u0442\u044C",
    cancelLabel: "\u041D\u0435 \u0441\u0435\u0439\u0447\u0430\u0441",
    onCancel: () => setAsk(false),
    onConfirm: () => {
      setAsk(false);
      onAllow();
    }
  })) : null);
}
Object.assign(window, {
  PermissionScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/wayback-app/PermissionScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/wayback-app/PhoneFrame.jsx
try { (() => {
function PhoneFrame({
  children,
  platform = 'ios',
  theme = 'light',
  label
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    "data-theme": theme === 'dark' ? 'dark' : undefined,
    "data-platform": platform === 'android' ? 'android' : undefined,
    style: {
      width: 390,
      height: 780,
      borderRadius: platform === 'android' ? 28 : 44,
      overflow: 'hidden',
      position: 'relative',
      display: 'flex',
      flexDirection: 'column',
      background: 'var(--wb-surface-default)',
      color: 'var(--wb-content-primary)',
      border: '1px solid var(--wb-border-subtle)',
      boxShadow: 'var(--wb-shadow-2)',
      fontFamily: 'var(--wb-font)'
    }
  }, /*#__PURE__*/React.createElement(StatusBar, {
    platform: platform
  }), children), label ? /*#__PURE__*/React.createElement("span", {
    style: {
      font: '600 11px/1 var(--wb-font-body)',
      letterSpacing: '.06em',
      textTransform: 'uppercase',
      color: 'var(--wb-content-tertiary)'
    }
  }, label) : null);
}
function StatusBar({
  platform
}) {
  const {
    Icon
  } = window.WaybackDesignSystem_38e35b;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: platform === 'android' ? '8px 16px 4px' : '14px 26px 6px',
      fontSize: 12.5,
      fontWeight: 600,
      color: 'var(--wb-content-primary)',
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("span", null, "9:41"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      gap: 5,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "signal_cellular_alt",
    size: 15
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "wifi_off",
    size: 15
  }), /*#__PURE__*/React.createElement(Icon, {
    name: "battery_full",
    size: 15
  })));
}
Object.assign(window, {
  PhoneFrame,
  StatusBar
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/wayback-app/PhoneFrame.jsx", error: String((e && e.message) || e) }); }

// ui_kits/wayback-app/PointsScreen.jsx
try { (() => {
function PointsScreen({
  points,
  activeId,
  platform,
  loading,
  onBack,
  onSelect,
  onDelete,
  onSave,
  onOpenSettings
}) {
  const {
    AppBar,
    IconButton,
    ListItem,
    Badge,
    Button,
    Icon,
    Skeleton,
    Dialog,
    Snackbar
  } = window.WaybackDesignSystem_38e35b;
  const [confirm, setConfirm] = React.useState(null);
  const [toast, setToast] = React.useState(null);
  const typeIcon = {
    car: 'directions_car',
    tent: 'camping',
    fishing: 'phishing',
    bag: 'backpack',
    house: 'cottage',
    meeting: 'group',
    parking: 'local_parking',
    generic: 'location_on'
  };
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(AppBar, {
    platform: platform,
    title: "\u0421\u043E\u0445\u0440\u0430\u043D\u0451\u043D\u043D\u044B\u0435 \u0442\u043E\u0447\u043A\u0438",
    onBack: onBack,
    actions: /*#__PURE__*/React.createElement(IconButton, {
      icon: "settings",
      label: "\u041D\u0430\u0441\u0442\u0440\u043E\u0439\u043A\u0438",
      onClick: onOpenSettings
    })
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto'
    }
  }, loading ? /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 'var(--wb-space-md)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--wb-space-lg)'
    }
  }, [0, 1, 2].map(i => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      display: 'flex',
      gap: 'var(--wb-space-md)',
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(Skeleton, {
    width: 40,
    height: 40,
    radius: "var(--wb-radius-full)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(Skeleton, {
    width: 150,
    height: 15
  }), /*#__PURE__*/React.createElement(Skeleton, {
    width: 100,
    height: 12
  }))))) : points.length === 0 ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      textAlign: 'center',
      gap: 'var(--wb-space-sm)',
      padding: 'var(--wb-space-4xl) var(--wb-space-xl)'
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "location_off",
    size: 48,
    color: "var(--wb-content-tertiary)"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 700,
      fontSize: 20
    }
  }, "\u041F\u043E\u043A\u0430 \u043D\u0435\u0442 \u0441\u043E\u0445\u0440\u0430\u043D\u0451\u043D\u043D\u044B\u0445 \u0442\u043E\u0447\u0435\u043A"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      color: 'var(--wb-content-secondary)',
      maxWidth: '36ch'
    }
  }, "\u0421\u043E\u0445\u0440\u0430\u043D\u0438\u0442\u0435 \u043C\u0435\u0441\u0442\u043E, \u0433\u0434\u0435 \u0432\u044B \u0441\u0435\u0439\u0447\u0430\u0441 \u0441\u0442\u043E\u0438\u0442\u0435 \u2014 \u043C\u0430\u0448\u0438\u043D\u0443, \u043B\u0430\u0433\u0435\u0440\u044C, \u043B\u044E\u0431\u043E\u0435 \u043C\u0435\u0441\u0442\u043E, \u043A\u043E\u0442\u043E\u0440\u043E\u0435 \u0437\u0430\u0445\u043E\u0442\u0438\u0442\u0435 \u043D\u0430\u0439\u0442\u0438 \u0441\u043D\u043E\u0432\u0430."), /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    icon: "add_location_alt",
    onClick: onSave,
    style: {
      marginTop: 'var(--wb-space-sm)'
    }
  }, "\u0421\u043E\u0445\u0440\u0430\u043D\u0438\u0442\u044C \u0442\u0435\u043A\u0443\u0449\u0435\u0435 \u043C\u0435\u0441\u0442\u043E\u043F\u043E\u043B\u043E\u0436\u0435\u043D\u0438\u0435")) : points.map(p => /*#__PURE__*/React.createElement(ListItem, {
    key: p.id,
    icon: typeIcon[p.type] || 'location_on',
    title: p.name,
    subtitle: `${p.distance} · ${p.saved}`,
    selected: p.id === activeId,
    onClick: () => onSelect(p.id),
    trailing: p.id === activeId ? /*#__PURE__*/React.createElement(Badge, {
      tone: "brand"
    }, "\u0410\u043A\u0442\u0438\u0432\u043D\u0430") : /*#__PURE__*/React.createElement(IconButton, {
      icon: "delete",
      label: `Удалить ${p.name}`,
      variant: "negative",
      size: 20,
      onClick: e => {
        e.stopPropagation();
        setConfirm(p);
      }
    })
  }))), points.length > 0 ? /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 'var(--wb-space-md)',
      paddingBottom: 'var(--wb-space-xl)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    icon: "add_location_alt",
    onClick: onSave,
    style: {
      width: '100%'
    }
  }, "\u0421\u043E\u0445\u0440\u0430\u043D\u0438\u0442\u044C \u0442\u0435\u043A\u0443\u0449\u0435\u0435 \u043C\u0435\u0441\u0442\u043E\u043F\u043E\u043B\u043E\u0436\u0435\u043D\u0438\u0435")) : null, toast ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 'var(--wb-space-md)',
      right: 'var(--wb-space-md)',
      bottom: 88
    }
  }, /*#__PURE__*/React.createElement(Snackbar, null, toast)) : null, confirm ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--wb-scrim)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(Dialog, {
    platform: platform,
    destructive: true,
    title: `Удалить «${confirm.name}»?`,
    body: "\u0412\u044B \u043F\u043E\u0442\u0435\u0440\u044F\u0435\u0442\u0435 \u0441\u043E\u0445\u0440\u0430\u043D\u0451\u043D\u043D\u043E\u0435 \u043C\u0435\u0441\u0442\u043E\u043F\u043E\u043B\u043E\u0436\u0435\u043D\u0438\u0435. \u041E\u0442\u043C\u0435\u043D\u0438\u0442\u044C \u044D\u0442\u043E \u0434\u0435\u0439\u0441\u0442\u0432\u0438\u0435 \u043D\u0435\u043B\u044C\u0437\u044F.",
    confirmLabel: "\u0423\u0434\u0430\u043B\u0438\u0442\u044C",
    cancelLabel: "\u041E\u0442\u043C\u0435\u043D\u0430",
    onCancel: () => setConfirm(null),
    onConfirm: () => {
      onDelete(confirm.id);
      setToast(`Точка «${confirm.name}» удалена`);
      setConfirm(null);
      setTimeout(() => setToast(null), 2600);
    }
  })) : null);
}
Object.assign(window, {
  PointsScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/wayback-app/PointsScreen.jsx", error: String((e && e.message) || e) }); }

// ui_kits/wayback-app/SaveSheet.jsx
try { (() => {
function SaveSheet({
  platform,
  onCancel,
  onSave
}) {
  const {
    BottomSheet,
    TextField,
    TypePicker,
    Button,
    Badge,
    Icon
  } = window.WaybackDesignSystem_38e35b;
  const [name, setName] = React.useState('');
  const [type, setType] = React.useState('car');
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--wb-scrim)',
      display: 'flex',
      alignItems: 'flex-end'
    },
    onClick: onCancel
  }, /*#__PURE__*/React.createElement(BottomSheet, {
    platform: platform,
    title: "\u0422\u043E\u0447\u043A\u0430 \u0441\u043E\u0445\u0440\u0430\u043D\u0435\u043D\u0430",
    style: {
      maxWidth: 'none'
    },
    onClick: e => e.stopPropagation()
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--wb-space-md)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 'var(--wb-space-xs)'
    }
  }, /*#__PURE__*/React.createElement(Badge, {
    tone: "positive"
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "gps_fixed",
    size: 14
  }), " \u0422\u043E\u0447\u043D\u043E\u0441\u0442\u044C \xB16 \u043C"), /*#__PURE__*/React.createElement(Badge, {
    tone: "neutral"
  }, "55.7558, 37.6173")), /*#__PURE__*/React.createElement(TextField, {
    label: "\u041D\u0430\u0437\u0432\u0430\u043D\u0438\u0435 \u0442\u043E\u0447\u043A\u0438",
    value: name,
    onChange: setName,
    placeholder: "\u041C\u0430\u0448\u0438\u043D\u0430",
    helper: "\u041C\u043E\u0436\u043D\u043E \u043E\u0441\u0442\u0430\u0432\u0438\u0442\u044C \u043F\u0443\u0441\u0442\u044B\u043C \u2014 \u043F\u043E\u0434\u0441\u0442\u0430\u0432\u0438\u043C \u0442\u0438\u043F \u0442\u043E\u0447\u043A\u0438"
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("span", {
    style: {
      font: '600 11.5px/1 var(--wb-font)',
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      color: 'var(--wb-content-tertiary)'
    }
  }, "\u0422\u0438\u043F \u0442\u043E\u0447\u043A\u0438"), /*#__PURE__*/React.createElement(TypePicker, {
    value: type,
    onChange: setType,
    style: {
      marginTop: 8
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 'var(--wb-space-sm)'
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "primary",
    style: {
      flex: 1
    },
    onClick: () => onSave(name, type)
  }, "\u0413\u043E\u0442\u043E\u0432\u043E"), /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    style: {
      flex: 1
    },
    onClick: onCancel
  }, "\u041E\u0442\u043C\u0435\u043D\u0430")))));
}
Object.assign(window, {
  SaveSheet
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/wayback-app/SaveSheet.jsx", error: String((e && e.message) || e) }); }

// ui_kits/wayback-app/SettingsScreen.jsx
try { (() => {
function SettingsScreen({
  platform,
  onBack,
  units,
  setUnits,
  vibrate,
  setVibrate,
  keepAwake,
  setKeepAwake
}) {
  const {
    AppBar,
    ListItem,
    Switch,
    SegmentedTabs,
    Icon,
    Card
  } = window.WaybackDesignSystem_38e35b;
  return /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(AppBar, {
    platform: platform,
    title: "\u041D\u0430\u0441\u0442\u0440\u043E\u0439\u043A\u0438",
    onBack: onBack
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: 'var(--wb-space-md)',
      display: 'flex',
      flexDirection: 'column',
      gap: 'var(--wb-space-xl)'
    }
  }, /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 11.5px/1 var(--wb-font)',
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      color: 'var(--wb-content-tertiary)',
      marginBottom: 'var(--wb-space-xs)'
    }
  }, "\u0415\u0434\u0438\u043D\u0438\u0446\u044B \u0438\u0437\u043C\u0435\u0440\u0435\u043D\u0438\u044F"), /*#__PURE__*/React.createElement(Card, {
    elevation: 1,
    padding: "var(--wb-space-md)"
  }, /*#__PURE__*/React.createElement(SegmentedTabs, {
    value: units,
    onChange: setUnits,
    items: [{
      id: 'm',
      label: 'Метры'
    }, {
      id: 'ft',
      label: 'Футы'
    }]
  }))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 11.5px/1 var(--wb-font)',
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      color: 'var(--wb-content-tertiary)',
      marginBottom: 'var(--wb-space-xs)'
    }
  }, "\u0412\u043E \u0432\u0440\u0435\u043C\u044F \u043D\u0430\u0432\u0438\u0433\u0430\u0446\u0438\u0438"), /*#__PURE__*/React.createElement("div", {
    style: {
      border: '1px solid var(--wb-border-subtle)',
      borderRadius: 'var(--wb-radius-md)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement(ListItem, {
    icon: "vibration",
    title: "\u0412\u0438\u0431\u0440\u0430\u0446\u0438\u044F \u043F\u0440\u0438 \u043F\u0440\u0438\u0431\u044B\u0442\u0438\u0438",
    subtitle: "\u041E\u0434\u0438\u043D \u0440\u0430\u0437 \u043F\u0440\u0438 \u0432\u0445\u043E\u0434\u0435 \u0432 \u0440\u0430\u0434\u0438\u0443\u0441",
    trailing: /*#__PURE__*/React.createElement(Switch, {
      checked: vibrate,
      onChange: setVibrate,
      platform: platform
    })
  }), /*#__PURE__*/React.createElement(ListItem, {
    icon: "brightness_high",
    title: "\u041D\u0435 \u0433\u0430\u0441\u0438\u0442\u044C \u044D\u043A\u0440\u0430\u043D",
    subtitle: "\u041F\u043E\u043A\u0430 \u043E\u0442\u043A\u0440\u044B\u0442 \u044D\u043A\u0440\u0430\u043D \u043D\u0430\u0432\u0438\u0433\u0430\u0446\u0438\u0438",
    divider: false,
    trailing: /*#__PURE__*/React.createElement(Switch, {
      checked: keepAwake,
      onChange: setKeepAwake,
      platform: platform
    })
  }))), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 11.5px/1 var(--wb-font)',
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      color: 'var(--wb-content-tertiary)',
      marginBottom: 'var(--wb-space-xs)'
    }
  }, "\u041E \u043F\u0440\u0438\u043B\u043E\u0436\u0435\u043D\u0438\u0438"), /*#__PURE__*/React.createElement("div", {
    style: {
      border: '1px solid var(--wb-border-subtle)',
      borderRadius: 'var(--wb-radius-md)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement(ListItem, {
    icon: "explore",
    title: "\u041A\u0430\u043B\u0438\u0431\u0440\u043E\u0432\u043A\u0430 \u043A\u043E\u043C\u043F\u0430\u0441\u0430",
    subtitle: "\u041F\u043E\u0432\u043E\u0434\u0438\u0442\u0435 \u0442\u0435\u043B\u0435\u0444\u043E\u043D\u043E\u043C \u0432 \u0444\u043E\u0440\u043C\u0435 \u0432\u043E\u0441\u044C\u043C\u0451\u0440\u043A\u0438",
    trailing: /*#__PURE__*/React.createElement(Icon, {
      name: "chevron_right",
      size: 20,
      color: "var(--wb-content-tertiary)"
    })
  }), /*#__PURE__*/React.createElement(ListItem, {
    icon: "info",
    title: "\u0412\u0435\u0440\u0441\u0438\u044F",
    subtitle: "0.1.0 \xB7 \u043E\u0444\u043B\u0430\u0439\u043D, \u0431\u0435\u0437 \u0430\u043A\u043A\u0430\u0443\u043D\u0442\u043E\u0432",
    divider: false
  })))));
}
Object.assign(window, {
  SettingsScreen
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/wayback-app/SettingsScreen.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Button = __ds_scope.Button;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.Avatar = __ds_scope.Avatar;

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.Chip = __ds_scope.Chip;

__ds_ns.Divider = __ds_scope.Divider;

__ds_ns.ListItem = __ds_scope.ListItem;

__ds_ns.Alert = __ds_scope.Alert;

__ds_ns.BottomSheet = __ds_scope.BottomSheet;

__ds_ns.Dialog = __ds_scope.Dialog;

__ds_ns.ProgressIndicator = __ds_scope.ProgressIndicator;

__ds_ns.Skeleton = __ds_scope.Skeleton;

__ds_ns.Snackbar = __ds_scope.Snackbar;

__ds_ns.Checkbox = __ds_scope.Checkbox;

__ds_ns.Radio = __ds_scope.Radio;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.TextArea = __ds_scope.TextArea;

__ds_ns.TextField = __ds_scope.TextField;

__ds_ns.POINT_TYPES = __ds_scope.POINT_TYPES;

__ds_ns.TypePicker = __ds_scope.TypePicker;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.AppBar = __ds_scope.AppBar;

__ds_ns.BackButton = __ds_scope.BackButton;

__ds_ns.BottomNav = __ds_scope.BottomNav;

__ds_ns.SegmentedTabs = __ds_scope.SegmentedTabs;

__ds_ns.CompassArrow = __ds_scope.CompassArrow;

})();
