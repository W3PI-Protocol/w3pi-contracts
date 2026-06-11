# Security Policy

## Security Scope

This repository contains the public source code for the W3PI protocol contracts.

Security review should focus on:

```text
contracts/W3PI_Core.sol
contracts/W3PIViewer.sol
```

## Ownerless Design

W3PI is designed as an ownerless protocol.

The deployed core contract is intended to have:

```text
No admin mint
No blacklist
No pause function
No owner-controlled fee changes
No post-deployment parameter control
No upgrade proxy
```

## Reporting Security Issues

If you discover a potential security issue, vulnerability, or incorrect contract behavior, please report it responsibly.

Contact:

```text
security@w3pi.social
```

If this email is not yet active, use the official website contact channel:

```text
https://w3pi.social
```

## Public Disclosure

Please do not publicly disclose a potential vulnerability before the issue has been reviewed.

Responsible security reports should include:

```text
Affected contract
Function name
Transaction or reproduction steps
Expected behavior
Observed behavior
Potential impact
Suggested fix if available
```

## Disclaimer

W3PI smart contracts are provided as public source code for transparency.

Users should independently review the contracts and understand the risks before interacting with any deployed contract.
