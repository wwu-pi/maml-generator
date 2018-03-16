/**
 */
package de.wwu.maml.maml2md2.correspondence.maml2md2.impl;

import de.wwu.maml.maml2md2.correspondence.maml2md2.*;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;

import org.eclipse.emf.ecore.impl.EFactoryImpl;

import org.eclipse.emf.ecore.plugin.EcorePlugin;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model <b>Factory</b>.
 * <!-- end-user-doc -->
 * @generated
 */
public class Maml2md2FactoryImpl extends EFactoryImpl implements Maml2md2Factory {
	/**
	 * Creates the default factory implementation.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public static Maml2md2Factory init() {
		try {
			Maml2md2Factory theMaml2md2Factory = (Maml2md2Factory)EPackage.Registry.INSTANCE.getEFactory(Maml2md2Package.eNS_URI);
			if (theMaml2md2Factory != null) {
				return theMaml2md2Factory;
			}
		}
		catch (Exception exception) {
			EcorePlugin.INSTANCE.log(exception);
		}
		return new Maml2md2FactoryImpl();
	}

	/**
	 * Creates an instance of the factory.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public Maml2md2FactoryImpl() {
		super();
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	@Override
	public EObject create(EClass eClass) {
		switch (eClass.getClassifierID()) {
			case Maml2md2Package.TRANSFORMATION: return createTransformation();
			case Maml2md2Package.CORR: return createCorr();
			case Maml2md2Package.BASIC_ELEM: return createBasicElem();
			default:
				throw new IllegalArgumentException("The class '" + eClass.getName() + "' is not a valid classifier");
		}
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public Transformation createTransformation() {
		TransformationImpl transformation = new TransformationImpl();
		return transformation;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public Corr createCorr() {
		CorrImpl corr = new CorrImpl();
		return corr;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public BasicElem createBasicElem() {
		BasicElemImpl basicElem = new BasicElemImpl();
		return basicElem;
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	public Maml2md2Package getMaml2md2Package() {
		return (Maml2md2Package)getEPackage();
	}

	/**
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @deprecated
	 * @generated
	 */
	@Deprecated
	public static Maml2md2Package getPackage() {
		return Maml2md2Package.eINSTANCE;
	}

} //Maml2md2FactoryImpl
